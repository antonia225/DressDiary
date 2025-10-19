import SwiftUI

struct SavedOutfit: Identifiable {
    let id: String
    let name: String
    let season: String
    let items: [ClothingItem]
    let itemIds: [Int]

    var previewImage: UIImage? {
        items.first?.image
    }
}

struct OutfitsView: View {
    @State private var outfits: [SavedOutfit] = []
    @State private var showAdd: Bool = false
    @AppStorage("currentUsername") private var currentUsername: String?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HeaderView(title: "DressDiary", showStreak: true)

                HStack {
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
            }
            VStack {
                if outfits.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tshirt.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.accentColor)
                        Text("No outfits yet")
                            .font(.headline)
                            .foregroundColor(Color("textColor"))
                        Text("Tap the plus button to start creating outfits.")
                            .font(.subheadline)
                            .foregroundColor(Color("captionColor"))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 22) {
                            ForEach(outfits) { outfit in OutfitCard(outfit: outfit) }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Outfits")
            .sheet(isPresented: $showAdd, onDismiss: load) {
                AddOutfitView()
            }
            .onAppear(perform: load)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }

    private func onAddItem() {
        showAdd = true
    }

    private func load() {
        guard let user = currentUsername,
              let arr = CppBridge.fetchOutfits(forUser: user) as? [[String: Any]] else {
            outfits = []
            return
        }

        outfits = arr.compactMap { dict in
            guard let id = dict["id"] as? String ?? (dict["id"] as? NSString).map({ String($0) }) else {
                return nil
            }
            let name = dict["name"] as? String ?? ""
            let season = dict["season"] as? String ?? ""

            let itemDicts = dict["items"] as? [[String: Any]] ?? []
            let items: [ClothingItem] = itemDicts.enumerated().compactMap { index, itemDict in
                ClothingItem(dictionary: itemDict, fallbackId: index)
            }

            let itemIds: [Int]
            if let ids = dict["itemIds"] as? [Int] {
                itemIds = ids
            } else if let ids = dict["itemIds"] as? [NSNumber] {
                itemIds = ids.map { $0.intValue }
            } else {
                itemIds = []
            }

            return SavedOutfit(
                id: id,
                name: name,
                season: season,
                items: items,
                itemIds: itemIds
            )
        }
    }
}
