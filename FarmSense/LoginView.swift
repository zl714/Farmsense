import SwiftUI

struct LoginView: View {
    // 👇 Add this property so the view accepts the closure
    var onLoginSuccess: () -> Void

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("FarmSense")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                Button("Forgot password?") {
                    // later: password reset
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
            .padding(.horizontal)

            Button(action: {
                // ✅ call the closure when login succeeds
                onLoginSuccess()
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Text("Or continue with")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                HStack(spacing: 24) {
                    VStack {
                        Image(systemName: "faceid")
                            .font(.largeTitle)
                        Text("Face ID")
                            .font(.caption)
                    }

                    VStack {
                        Image(systemName: "touchid")
                            .font(.largeTitle)
                        Text("Touch ID")
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    // 👇 For previews, pass an empty closure
    LoginView(onLoginSuccess: {})
}
