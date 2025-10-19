import SwiftUI

@main
struct DressDiaryApp: App {
    // hook up our legacy AppDelegate for Core Data
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var isShowingLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isShowingLaunchScreen {
                    LaunchScreen()
                        .ignoresSafeArea()
                        .onAppear {
                            let preferred = ThemeManager.ensureStoredTheme()
                            let sync = UserDefaults.standard.bool(forKey: "syncSystemTheme")
                            ThemeManager.applyTheme(selectedTheme: preferred, syncWithSystem: sync)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                isShowingLaunchScreen = false
                            }
                        }
                } else if let user = currentUsername, !user.isEmpty {
                    MainTabView()
                        .onAppear {
                            if CppBridge.recoverUser(fromCoreData: user) {
                                let preferred = ThemeManager.ensureStoredTheme()
                                let sync = UserDefaults.standard.bool(forKey: "syncSystemTheme")
                                ThemeManager.applyTheme(selectedTheme: preferred, syncWithSystem: sync)
                            }
                        }
                } else {
                    LoginView()
                        .onAppear {
                            let preferred = ThemeManager.ensureStoredTheme()
                            let sync = UserDefaults.standard.bool(forKey: "syncSystemTheme")
                            ThemeManager.applyTheme(selectedTheme: preferred, syncWithSystem: sync)
                        }
                }
            }
        }
    }
}
