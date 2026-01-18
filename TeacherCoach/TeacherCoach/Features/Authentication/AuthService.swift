import Foundation
import AuthenticationServices

/// Service for handling Google SSO authentication
@MainActor
final class AuthService: ObservableObject {
    private let config: AppConfiguration
    private let keychain = KeychainService.shared

    @Published var isAuthenticating = false
    @Published var authError: AuthError?

    init(config: AppConfiguration) {
        self.config = config
    }

    // MARK: - Public Methods

    /// Initiates Google Sign-In flow
    func signIn() async throws -> SessionToken {
        isAuthenticating = true
        authError = nil

        defer { isAuthenticating = false }

        do {
            // Get Google ID token via ASWebAuthenticationSession
            let idToken = try await performGoogleSignIn()

            // Validate token with backend (domain verification happens server-side)
            let session = try await validateWithBackend(idToken: idToken)

            // Store session in Keychain
            if let sessionData = try? JSONEncoder().encode(session) {
                _ = keychain.store(key: KeychainKeys.sessionToken, data: sessionData)
            }

            return session
        } catch let error as AuthError {
            authError = error
            throw error
        } catch {
            let authErr = AuthError.unknown(error)
            authError = authErr
            throw authErr
        }
    }

    /// Signs out the current user
    func signOut() {
        keychain.delete(key: KeychainKeys.sessionToken)
        keychain.delete(key: KeychainKeys.refreshToken)
    }

    /// Returns the current session if valid
    func getCurrentSession() -> SessionToken? {
        guard let data = keychain.retrieve(key: KeychainKeys.sessionToken),
              let session = try? JSONDecoder().decode(SessionToken.self, from: data),
              session.isValid else {
            return nil
        }
        return session
    }

    /// Refreshes the current session if needed
    func refreshSessionIfNeeded() async throws -> SessionToken? {
        guard let currentSession = getCurrentSession() else {
            return nil
        }

        // Refresh if expiring within 1 hour
        let oneHourFromNow = Date().addingTimeInterval(3600)
        if currentSession.expiresAt < oneHourFromNow {
            return try await refreshSession(currentSession)
        }

        return currentSession
    }

    // MARK: - Private Methods

    private func performGoogleSignIn() async throws -> String {
        // Build OAuth URL for Google
        let clientID = config.googleClientID

        // Validate Client ID is configured
        guard !clientID.isEmpty else {
            throw AuthError.missingClientID
        }

        let redirectURI = "com.peninsula.teachercoach:/oauth2callback"
        let scope = "openid email profile"

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "id_token"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "nonce", value: UUID().uuidString),
            URLQueryItem(name: "hd", value: config.allowedDomain),  // Hint for domain
            URLQueryItem(name: "prompt", value: "select_account")
        ]

        guard let authURL = components.url else {
            throw AuthError.unknown(NSError(domain: "AuthService", code: -1))
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "com.peninsula.teachercoach"
            ) { callbackURL, error in
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: AuthError.cancelled)
                    } else {
                        continuation.resume(throwing: AuthError.networkError(error))
                    }
                    return
                }

                guard let callbackURL = callbackURL,
                      let fragment = callbackURL.fragment,
                      let idToken = self.extractIDToken(from: fragment) else {
                    continuation.resume(throwing: AuthError.unknown(
                        NSError(domain: "AuthService", code: -2, userInfo: [
                            NSLocalizedDescriptionKey: "Failed to extract ID token"
                        ])
                    ))
                    return
                }

                continuation.resume(returning: idToken)
            }

            session.presentationContextProvider = AuthPresentationContext.shared
            session.prefersEphemeralWebBrowserSession = false

            if !session.start() {
                continuation.resume(throwing: AuthError.unknown(
                    NSError(domain: "AuthService", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to start authentication session"
                    ])
                ))
            }
        }
    }

    private func extractIDToken(from fragment: String) -> String? {
        let params = fragment.split(separator: "&")
        for param in params {
            let keyValue = param.split(separator: "=", maxSplits: 1)
            if keyValue.count == 2 && keyValue[0] == "id_token" {
                return String(keyValue[1])
            }
        }
        return nil
    }

    private func validateWithBackend(idToken: String) async throws -> SessionToken {
        let url = config.backendURL.appendingPathComponent("auth/validate")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["id_token": idToken]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError(NSError(domain: "AuthService", code: -4))
        }

        switch httpResponse.statusCode {
        case 200:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return SessionToken(
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
                expiresAt: Date().addingTimeInterval(TimeInterval(authResponse.expiresIn)),
                user: authResponse.user
            )
        case 403:
            throw AuthError.invalidDomain
        case 401:
            throw AuthError.tokenExpired
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AuthError.unknown(NSError(
                domain: "AuthService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
        }
    }

    private func refreshSession(_ session: SessionToken) async throws -> SessionToken {
        guard let refreshToken = session.refreshToken else {
            throw AuthError.tokenExpired
        }

        let url = config.backendURL.appendingPathComponent("auth/refresh")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["refresh_token": refreshToken]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenExpired
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        let newSession = SessionToken(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(authResponse.expiresIn)),
            user: authResponse.user
        )

        if let sessionData = try? JSONEncoder().encode(newSession) {
            _ = keychain.store(key: KeychainKeys.sessionToken, data: sessionData)
        }

        return newSession
    }
}

// MARK: - Supporting Types

private struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}

// MARK: - Presentation Context

private class AuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthPresentationContext()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first!
    }
}
