import SwiftUI

struct ClosetView: View {
    @State private var items: [ClothingItem] = []
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var showAdd: Bool = false
    @State private var filteredItems: [ClothingItem]? = nil
    @State private var isFiltering: Bool = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isFiltering {
                    FilterPageView(
                        items: items,
                        onFilterApplied: { result in
                            filteredItems = result
                            isFiltering = false
                        },
                        onShowAll: {
                            filteredItems = items
                            isFiltering = false
                        },
                        onAddItem: {
                            showAdd = true
                        }
                    )
                } else {
                    FilteredClothesView(
                        items: filteredItems ?? [],
                        onBackToFilters: {
                            isFiltering = true
                        },
                        onAddItem: {
                            showAdd = true
                        }
                    )
                }
            }
            .navigationTitle("DressDiary")
        }
        .sheet(isPresented: $showAdd, onDismiss: load) {
            AddItemView()
        }
        .onAppear(perform: load)
        .background(Color("BackgroundColor"))
    }
    
    private func load() {
        guard let user = currentUsername,
              let arr = CppBridge.fetchClothingItems(forUser: user) as? [[String: Any]] else { return }
        
        items = arr.enumerated().compactMap { idx, dict in
            ClothingItem(dictionary: dict, fallbackId: idx)
        }
    }
}
