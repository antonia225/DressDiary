import SwiftUI

struct FilteredClothesView: View {
    let items: [ClothingItem]
    let onBackToFilters: () -> Void
    let onAddItem: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 16) {
            HeaderView(title: "DressDiary", showStreak: true)

            HStack {
                Button(action: onBackToFilters) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Filters")
                    }
                }
                .foregroundColor(.accentColor)
                .padding(.leading)

                Spacer()

                Button(action: onAddItem) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                }
                .foregroundColor(.accentColor)
                .padding(.trailing)
            }
            .padding(.top)

            if items.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 40))
                        .padding(.bottom, 8)
                    Text("No items match your filters.")
                        .font(.headline)
                        .foregroundColor(Color("textColor").opacity(0.8))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items) { item in
                            ClothingItemCard(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
}
