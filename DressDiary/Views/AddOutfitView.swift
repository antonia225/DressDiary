import SwiftUI
import UniformTypeIdentifiers

private let clothingItemUTType = UTType.plainText

private struct DroppedClothingItem: Identifiable {
    let id: Int
    var item: ClothingItem
    var location: CGPoint
}

struct AddOutfitView: View {
    @Environment(\.presentationMode) private var presentation
    @AppStorage("currentUsername") private var currentUsername: String?

    @State private var availableItems: [ClothingItem] = []
    @State private var droppedItems: [DroppedClothingItem] = []

    @State private var isPaletteVisible: Bool = false
    @State private var isDragging: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingDetailsSheet: Bool = false

    @State private var name: String = ""
    @State private var season: String = ""
    @State private var date: Date = Date()

    private var selectedItemIds: Set<Int> {
        Set(droppedItems.map(\.id))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("BackgroundColor").ignoresSafeArea()

            OutfitCanvasView(
                availableItems: availableItems,
                droppedItems: $droppedItems,
                isDragging: $isDragging,
                onRemove: removeDroppedItem
            )
            .padding(.vertical, 40)
            .padding(.horizontal, 24)

            if isPaletteVisible {
                paletteOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .opacity(isDragging ? 0.0 : 1.0)
                    .allowsHitTesting(!isDragging)
            }

            controlsBar
        }
        .sheet(isPresented: $isShowingDetailsSheet, onDismiss: resetDetailFormIfNeeded) {
            detailsSheet
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Warning"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            loadItems()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isPaletteVisible = true
            }
        }
    }

    private var controlsBar: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isPaletteVisible = true
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.accentColor)
                    .padding(12)

            }
            .padding(.leading, 24)
            .padding(.bottom, 32)

            Spacer()

            Button {
                handleSaveTapped()
            } label: {
                Text("Save Outfit")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .foregroundColor(Color.white)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 32)
        }
    }

    private var paletteOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Closet Items")
                    .font(.headline)
                    .foregroundColor(Color("textColor"))
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isPaletteVisible = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("textColor"))
                        .font(.title2)
                }
            }

            if availableItems.isEmpty {
                Text("No clothing items available yet.")
                    .font(.subheadline)
                    .foregroundColor(Color("textColor"))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(availableItems) { item in
                            ClothingPaletteCard(
                                item: item,
                                isSelected: selectedItemIds.contains(item.id)
                            )
                            .onDrag {
                                DispatchQueue.main.async {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isDragging = true
                                    }
                                }
                                return NSItemProvider(object: "\(item.id)" as NSString)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("FieldColor"))
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 120)
    }

    private var detailsSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Season", text: $season)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Finalize Outfit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingDetailsSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        commitOutfit()
                    }
                }
            }
        }
    }

    private func handleSaveTapped() {
        guard !droppedItems.isEmpty else {
            alertMessage = "Drag at least one item onto the board before saving."
            showAlert = true
            return
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isPaletteVisible = false
        }
        isShowingDetailsSheet = true
    }

    private func commitOutfit() {
        guard let user = currentUsername else {
            alertMessage = "No user logged in."
            showAlert = true
            return
        }

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !season.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please complete all outfit details."
            showAlert = true
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateStr = formatter.string(from: date)
        let ids = droppedItems.map { NSNumber(value: $0.id) }

        let success = CppBridge.saveOutfit(
            forUser: user,
            name: name,
            dateAdded: dateStr,
            season: season,
            itemIds: ids
        )

        if success {
            droppedItems.removeAll()
            isPaletteVisible = false
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to save outfit."
            showAlert = true
        }
    }

    private func loadItems() {
        guard let user = currentUsername,
              let arr = CppBridge.fetchClothingItems(forUser: user) as? [[String: Any]] else {
            availableItems = []
            droppedItems = []
            return
        }

        let items = arr.enumerated().compactMap { idx, dict in
            ClothingItem(dictionary: dict, fallbackId: idx)
        }
        availableItems = items

        let lookup = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        droppedItems = droppedItems.compactMap { dropped in
            guard let updated = lookup[dropped.id] else { return nil }
            return DroppedClothingItem(id: dropped.id, item: updated, location: dropped.location)
        }
    }

    private func removeDroppedItem(_ dropped: DroppedClothingItem) {
        droppedItems.removeAll { $0.id == dropped.id }
    }

    private func resetDetailFormIfNeeded() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isDragging = false
            if droppedItems.isEmpty {
                isPaletteVisible = true
            }
        }
    }
}

// MARK: - Canvas View

private struct OutfitCanvasView: View {
    let availableItems: [ClothingItem]
    @Binding var droppedItems: [DroppedClothingItem]
    @Binding var isDragging: Bool
    var onRemove: (DroppedClothingItem) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color("FieldColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .foregroundColor(Color("dashColor"))
                    )

                if droppedItems.isEmpty {
                    Text("Tap '+' to open your closet, then drag items here")
                        .font(.headline)
                        .foregroundColor(Color("captionColor"))
                        .multilineTextAlignment(.center)
                }

                ForEach(droppedItems) { dropped in
                    DroppedItemView(item: dropped.item) {
                        onRemove(dropped)
                    }
                    .position(dropped.location)
                    .animation(.spring(response: 0.32, dampingFraction: 0.75), value: dropped.location)
                }
            }
            .onDrop(
                of: [clothingItemUTType],
                delegate: OutfitCanvasDropDelegate(
                    canvasSize: geo.size,
                    availableItems: availableItems,
                    droppedItems: $droppedItems,
                    isDragging: $isDragging
                )
            )
        }
    }
}

private struct DroppedItemView: View {
    let item: ClothingItem
    var onRemove: () -> Void

    var body: some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFill()
            .frame(width: 86, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 14))

        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("FieldColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color("textColor"))
                    .background(Color("FieldColor"))
                    .clipShape(Circle())
            }
            .offset(x: 10, y: -10)
            .buttonStyle(.plain)
        }
        .contextMenu {
            Button(role: .destructive, action: onRemove) {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}

private struct ClothingPaletteCard: View {
    let item: ClothingItem
    let isSelected: Bool

    var body: some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFill()
            .frame(height: 145)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct OutfitCanvasDropDelegate: DropDelegate {
    let canvasSize: CGSize
    let availableItems: [ClothingItem]
    @Binding var droppedItems: [DroppedClothingItem]
    @Binding var isDragging: Bool

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [clothingItemUTType])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [clothingItemUTType]).first else {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) { isDragging = false }
            }
            return false;
        }

        let dropPoint = info.location
        provider.loadObject(ofClass: NSString.self) { object, _ in
            defer {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isDragging = false
                    }
                }
            }
            guard let string = object as! String?,
                  let id = Int(string),
                  let item = availableItems.first(where: { $0.id == id }) else {
                return
            }

            DispatchQueue.main.async {
                let clampedLocation = clampPoint(dropPoint, in: canvasSize)
                if let index = droppedItems.firstIndex(where: { $0.id == id }) {
                    droppedItems[index].item = item
                    droppedItems[index].location = clampedLocation
                } else {
                    droppedItems.append(
                        DroppedClothingItem(id: id, item: item, location: clampedLocation)
                    )
                }
            }
        }
        return true
    }

    func dropEnded(info: DropInfo) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                isDragging = false
            }
        }
    }

    private func clampPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 70
        let maxX = max(padding, size.width - padding)
        let maxY = max(padding, size.height - padding)
        let x = min(max(point.x, padding), maxX)
        let y = min(max(point.y, padding), maxY)
        return CGPoint(x: x, y: y)
    }
}
