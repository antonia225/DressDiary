import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "BackgroundColor") ?? UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home",    systemImage: "house.fill") }
            
            ClosetView()
                .tabItem { Label("Closet",  systemImage: "cabinet.fill") }
            
            OutfitsView()
                .tabItem { Label("Outfits", systemImage: "tshirt.fill") }
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(.accentColor)
        .background(
            Color("BackgroundColor")
                .ignoresSafeArea(edges: .all)
        )
    }
}
