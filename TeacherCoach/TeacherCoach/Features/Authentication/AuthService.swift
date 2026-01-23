import Foundation
import GoogleSignIn
import AppKit

/// Service for handling Google SSO authentication
@MainActor
final class AuthService: ObservableObject {
    private let config: AppConfiguration
    private let keychain = KeychainService.shared

    @Published var isAuthenticating = false
    @Published var authError: AuthError?

    init(config: AppConfiguration) {
        self.config = config
        configureGoogleSignIn()
    }

    private func configureGoogleSignIn() {
        guard !config.googleClientID.isEmpty else { return }
        let gidConfig = GIDConfiguration(
            clientID: config.googleClientID,
            serverClientID: nil,
            hostedDomain: config.allowedDomain,
            openIDRealm: nil
        )
        GIDSignIn.sharedInstance.configuration = gidConfig
    }

    // MARK: - Public Methods

    /// Initiates Google Sign-In flow
    func signIn() async throws -> SessionToken {
        isAuthenticating = true
        authError = nil

        defer { isAuthenticating = false }

        // MARK: - Development Bypass
        // Enable with DEV_BYPASS_AUTH=1 environment variable in Xcode scheme.
        // Allows local testing without Google OAuth configuration.
        // The mock token is rejected by production backend - safe to leave enabled.
        if config.devBypassAuth {
            let mockUser = User(
                id: "dev-user",
                email: "developer@psd401.net",
                displayName: "Dev User",
                photoURL: nil
            )
            let mockSession = SessionToken(
                accessToken: "dev-token",
                refreshToken: nil,
                expiresAt: Date().addingTimeInterval(86400 * 365), // 1 year
                user: mockUser
            )
            if let sessionData = try? JSONEncoder().encode(mockSession) {
                _ = keychain.store(key: KeychainKeys.sessionToken, data: sessionData)
            }
            return mockSession
        }

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
        GIDSignIn.sharedInstance.signOut()
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
        guard !config.googleClientID.isEmpty else {
            throw AuthError.missingClientID
        }

        guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else {
            throw AuthError.unknown(NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No window available for sign-in"]
            ))
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown(NSError(
                    domain: "AuthService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No ID token in sign-in result"]
                ))
            }

            return idToken
        } catch let error as GIDSignInError {
            switch error.code {
            case .canceled:
                throw AuthError.cancelled
            default:
                throw AuthError.unknown(NSError(
                    domain: "GoogleSignIn",
                    code: error.code.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: "Google Sign-In error: \(error.localizedDescription)"]
                ))
            }
        } catch {
            throw AuthError.unknown(error)
        }
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

