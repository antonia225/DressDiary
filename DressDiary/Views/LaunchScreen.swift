import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack {
                Text("Dress")
                Text("Diary")
            }
            .font(.custom("Snell Roundhand", size: 100))
            .foregroundColor(Color("textColor"))
            .multilineTextAlignment(.center)
        }
    }
}
