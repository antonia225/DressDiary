import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredTheme") private var storedTheme: String = ""
    @AppStorage("syncSystemTheme") private var syncWithSystemTheme: Bool = false
    @State private var selectedTheme: String = "dark"

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $selectedTheme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(syncWithSystemTheme)
                .onChange(of: selectedTheme) { _, newValue in
                    guard !syncWithSystemTheme else { return }
                    storedTheme = newValue
                    ThemeManager.applyTheme(selectedTheme: newValue, syncWithSystem: false)
                }

                Toggle("Match system theme", isOn: $syncWithSystemTheme)
                    .onChange(of: syncWithSystemTheme) { _, newValue in
                        if newValue {
                            let system = ThemeManager.currentSystemTheme()
                            selectedTheme = system
                            storedTheme = system
                        } else {
                            if storedTheme.isEmpty {
                                storedTheme = ThemeManager.ensureStoredTheme()
                            }
                            selectedTheme = storedTheme
                        }
                        ThemeManager.applyTheme(selectedTheme: selectedTheme, syncWithSystem: newValue)
                    }
            }
        }
        .onAppear(perform: onAppear)
        .navigationTitle("Settings")
    }

    private func onAppear() {
        let ensured = ThemeManager.ensureStoredTheme()
        if storedTheme.isEmpty {
            storedTheme = ensured
        }

        if syncWithSystemTheme {
            selectedTheme = ThemeManager.currentSystemTheme()
        } else {
            selectedTheme = storedTheme
        }

        ThemeManager.applyTheme(selectedTheme: selectedTheme, syncWithSystem: syncWithSystemTheme)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
