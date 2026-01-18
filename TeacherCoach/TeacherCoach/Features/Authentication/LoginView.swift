import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.serviceContainer) private var services

    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 32) {
            // Logo and title
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.tint)

                Text("Teacher Coach")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("AI-Powered Teaching Feedback")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Domain notice
            VStack(spacing: 8) {
                Text("Peninsula School District")
                    .font(.headline)

                Text("Sign in with your @psd401.net account")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Sign in button
            Button {
                signIn()
            } label: {
                HStack {
                    if isSigningIn {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "person.badge.key.fill")
                    }
                    Text(isSigningIn ? "Signing in..." : "Sign in with Google")
                }
                .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isSigningIn)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .padding()
                    .background(.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Spacer()

            // Footer
            VStack(spacing: 4) {
                Text("Your audio stays on your device")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Only transcripts are sent for analysis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(48)
        .background(
            LinearGradient(
                colors: [.clear, .accentColor.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func signIn() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                let session = try await services.authService.signIn()
                appState.currentUser = session.user
                appState.isAuthenticated = true
            } catch let error as AuthError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }

            isSigningIn = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .environment(ServiceContainer.shared)
}
