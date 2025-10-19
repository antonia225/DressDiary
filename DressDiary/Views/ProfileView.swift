import SwiftUI

struct ProfileView: View {
    @AppStorage("currentUsername") private var currentUsername: String?
    @Environment(\.presentationMode) private var presentation

    @State private var clothesCount = 0
    @State private var outfitsCount = 0
    @State private var streak: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(title: "DressDiary", showStreak: false)
                
                // Imaginea banner
                Image("placeholderCard")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                
                // Avatar suprapus parțial peste banner
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 108, height: 108)
                      
                    Image("placeholderAvatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                .offset(y: -54) // urcă jumătate din cerc peste banner
                .padding(.bottom, -54) // elimină spațiul creat de offset
                
                // Utilizator
                Text(currentUsername ?? "Guest")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("textColor"))
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                // Statistici
                HStack(spacing: 0) {
                    statBlock(value: clothesCount, label: "clothes")
                    Divider()
                    statBlock(value: outfitsCount, label: "outfits")
                    Divider()
                    statBlock(value: streak, label: "streak")
                }
                .frame(height: 80)
                .background(Color("BackgroundColor"))
                .padding(.top, 16)
                
                Spacer()
                
                // Logout Button
                if currentUsername != nil {
                    Button(action: {
                        currentUsername = nil
                        presentation.wrappedValue.dismiss()}) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log out")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.accent)
                        .cornerRadius(10)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
        .onAppear {
            if let username = currentUsername {
                clothesCount = Int(CppBridge.getClothingItemCount(forUser: username))
                outfitsCount = Int(CppBridge.getOutfitCount(forUser: username))
                streak = Int(CppBridge.getCurrentStreak())
            }
        }
    }

    private func statBlock(value: Int, label: String) -> some View {
        VStack {
            Text("\(value)")
                .font(.system(size: 18))
                .foregroundColor(Color("textColor"))
                .padding(.bottom, 6)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("captionColor"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
