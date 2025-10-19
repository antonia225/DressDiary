import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) private var presentation
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("currentUsername") private var currentUsername: String?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("DressDiary")
                .font(.custom("Snell Roundhand", size: 60))
                .foregroundColor(Color("textColor"))
                .padding(.top, 10)
                .padding(.bottom, 32)

            Group {
                TextField("Name", text: $name)
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            .padding()
            .background(Color("FieldColor"))
            .cornerRadius(8)
            .foregroundColor(Color("textColor"))
            .autocapitalization(.none)
            .padding(.horizontal, 32)

            Button("Sign In", action: signUpTapped)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.accent)
                .cornerRadius(8)
                .foregroundColor(.white)
                .font(.system(.headline, weight: .semibold))
                .padding(.horizontal, 32)
                .padding(.top, 16)
            
            // Text("By clicking Sign In, you agree to our Terms of Service and Privacy policy")
            //     .font(.caption)
            //     .foregroundColor(Color("textColor"))
            //     .padding(.bottom, 16)
            //     .multilineTextAlignment(.center)

            Spacer()

            Button("Cancel") {
                presentation.wrappedValue.dismiss()
            }
            .foregroundColor(Color("textColor"))
            .padding(.bottom, 16)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Eroare"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signUpTapped() {
        let n = name.trimmingCharacters(in: .whitespaces)
        let u = username.trimmingCharacters(in: .whitespaces)
        let p = password

        guard !n.isEmpty && !u.isEmpty && !p.isEmpty else {
            alertMessage = "Completează toate câmpurile."
            showAlert = true
            return
        }

        if CppBridge.createUser(u, name: n, password: p) {
            currentUsername = u
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Username deja folosit."
            showAlert = true
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
