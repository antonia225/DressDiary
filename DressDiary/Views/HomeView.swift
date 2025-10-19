import SwiftUI

struct HomeView: View {
    @State private var suggestion: (name: String, season: String, image: UIImage)?
    @State private var streak: Int = 0
    @AppStorage("currentUsername") private var currentUsername: String?
    let totalWidth = UIScreen.main.bounds.width * 0.25
    let greetings = ["have a nice day!", "what a beautiful day!", "time to rule the world!", "good to see you!"]
    @State private var greeting = "Hello"
    @State private var fullName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: "DressDiary", showStreak: true)
            
            VStack(spacing: 0) {
                    Text("\(fullName),")
                        .font(.title2)
                        .foregroundColor(Color("textColor"))
                    Text("\(greeting)")
                        .font(.title2)
                        .foregroundColor(Color("textColor"))
                        .onAppear {
                            greeting = greetings.randomElement() ?? "hello!"
                            fullName = CppBridge.getCurrentName()
                        }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(40)

            VStack(alignment: .leading) {
                if let s = suggestion {
                    Image(uiImage: s.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .clipped()
                        .cornerRadius(12)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(s.season.capitalized)
                            .font(.subheadline)
                            .foregroundColor(Color("textColor"))
                    }
                    .padding(.horizontal)
                    Text("Today's suggestion.")
                        .font(.system(.headline))
                        .foregroundColor(Color("textColor"))
                } else {
                    Image("placeholderCard")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .clipped()
                        .padding(.horizontal, 10)
                        .cornerRadius(12)
                        .padding(.top, 10)
                    Text("No suggestion today")
                        .padding(.horizontal)
                        .foregroundColor(Color("textColor"))
                    Text("Try adding an outfit first.")
                        .foregroundColor(Color("captionColor").opacity(0.4))
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
            .background(Color("FieldColor"))
            .cornerRadius(12)
            .padding()

            Spacer()
        }
        .background(Color("BackgroundColor"))
        .onAppear(perform: loadSuggestion)
    }

    private func loadSuggestion() {
        guard let user = currentUsername,
              let dict = CppBridge.getTodaySuggestion(forUser: user) as? [String: Any],
              let name = dict["name"] as? String,
              let season = dict["season"] as? String
        else {
            suggestion = nil
            return
        }
        let itemDicts = dict["items"] as? [[String: Any]] ?? []
        if let firstImage = itemDicts.compactMap({ itemDict -> UIImage? in
            guard let data = itemDict["image"] as? Data, !data.isEmpty else { return nil }
            return UIImage(data: data)
        }).first {
            suggestion = (name: name, season: season, image: firstImage)
        } else {
            suggestion = nil
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
