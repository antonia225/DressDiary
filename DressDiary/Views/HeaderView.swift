import SwiftUI

struct HeaderView: View {
    let title: String
    let showStreak: Bool
    let totalWidth = UIScreen.main.bounds.width * 0.25
    @State private var streak: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.custom("Snell Roundhand", size: 35))
                    .foregroundColor(Color("textColor"))

                Spacer()

                HStack(spacing: 8) {
                    // Streak
                    if showStreak {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.accentColor)
                            Text("\(streak)")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .onAppear {
                            streak = Int(CppBridge.getCurrentStreak())
                        }
                        .padding(.horizontal, 6)
                        .frame(width: totalWidth * 0.75)
                    }

                    // Setări
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color("textColor"))
                    }
                    .padding(.horizontal, 6)
                    .cornerRadius(8)
                    .frame(width: totalWidth * 0.25)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider()
                .frame(height: 0.75)
                .background(Color("textColor"))
                .padding(.top, 5)
        }
    }
}
