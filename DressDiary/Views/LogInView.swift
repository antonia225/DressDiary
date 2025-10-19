import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("currentUsername") private var currentUsername: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("BackgroundColor").ignoresSafeArea()

            VStack {
                Spacer()
                
                VStack(spacing: 32) {
                    Text("DressDiary")
                        .font(.custom("Snell Roundhand Bold", size: 50))
                        .padding(.bottom, 30)
                        .foregroundColor(Color("textColor"))

                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color("FieldColor"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color("FieldColor"))
                            .cornerRadius(8)
                            .foregroundColor(Color("textColor"))
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    Button(action: logInTapped) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .font(.system(.headline, weight: .semibold))
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.horizontal)

                Spacer()
            }

            // Buton Sign In sus-dreapta
            Button("Sign In") {
                showingSignUp = true
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Eroare"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    @State private var showingSignUp = false

    private func logInTapped() {
        let user = username.trimmingCharacters(in: .whitespaces)
        let pass = password

        guard !user.isEmpty && !pass.isEmpty else {
            alertMessage = "Completează username și parolă."
            showAlert = true
            return
        }

        if CppBridge.loginUser(user, password: pass) != nil {
            currentUsername = user
        } else {
            alertMessage = "Username sau parolă incorectă."
            showAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
