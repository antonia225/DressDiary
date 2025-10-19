import SwiftUI

struct FilterPageView: View {
    let items: [ClothingItem]
    var onFilterApplied: ([ClothingItem]) -> Void
    var onShowAll: () -> Void
    var onAddItem: () -> Void

    @State private var selectedColors: Set<String> = []
    @State private var selectedMaterials: Set<String> = []
    @State private var selectedCategories: Set<String> = []

    private let colors: [String] = [
        "red","orange","yellow","green","blue","purple",
        "pink","brown","black","white","gray","other"
    ]
    private let materials: [String] = [
        "cotton","denim","leather","wool","silk","linen","polyester"
    ]
    private let categories: [(name: String, image: String)] = [
        ("Tops","topIcon"), ("Pants","pantsIcon"),
        ("Jackets","jacketIcon"), ("Shoes","shoesIcon"),
        ("Accessories","accessoriesIcon")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(title: "DressDiary", showStreak: true)
                headerSection
                colorSection
                materialSection
                categorySection
                applyButton
            }
        }

    }

    private var headerSection: some View {
        HStack {
            Button("View All", action: onShowAll)
                .foregroundColor(.accentColor)
            Spacer()
            Button(action: onAddItem) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
            }
            .foregroundColor(.accentColor)
        }
        .padding(.horizontal)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Colors").font(.headline).padding(.horizontal)
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    let fill: AnyShapeStyle = color == "other"
                        ? AnyShapeStyle(AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red]),
                            center: .center))
                        : AnyShapeStyle(getColor(from: color))

                    Circle()
                        .fill(fill)
                        .overlay(Circle().stroke(Color("dashColor"), lineWidth: selectedColors.contains(color) ? 3 : 1))
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            if selectedColors.contains(color) {
                                selectedColors.remove(color)
                            } else {
                                selectedColors.insert(color)
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var materialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Materials").font(.headline).padding(.horizontal)
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 12) {
                ForEach(materials, id: \.self) { mat in
                    Text(mat.capitalized)
                        .font(.subheadline)
                        .foregroundColor(selectedMaterials.contains(mat) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedMaterials.contains(mat) ? Color.accentColor : Color(.systemGray5))
                        )
                        .onTapGesture {
                            if selectedMaterials.contains(mat) {
                                selectedMaterials.remove(mat)
                            } else {
                                selectedMaterials.insert(mat)
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories").font(.headline).padding(.horizontal)
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 12) {
                ForEach(categories, id: \.name) { cat in
                    HStack(spacing: 8) {
                        Text(cat.name).foregroundColor(.primary)
                        Spacer()
                        Image(cat.image)
                            .resizable().scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedCategories.contains(cat.name) ? Color.accentColor : Color(.systemGray5))
                    )
                    .foregroundColor(selectedCategories.contains(cat.name) ? .white : .primary)
                    .onTapGesture {
                        if selectedCategories.contains(cat.name) {
                            selectedCategories.remove(cat.name)
                        } else {
                            selectedCategories.insert(cat.name)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var applyButton: some View {
        Button("Apply Filters") {
            let filtered = items.filter { item in
                let matchColor = selectedColors.isEmpty
                    || selectedColors.contains(item.color.lowercased())
                let matchMat = selectedMaterials.isEmpty
                    || item.materials.contains(where: { selectedMaterials.contains($0.lowercased()) })
                let matchCat = selectedCategories.isEmpty
                    || selectedCategories.contains(item.category)
                return matchColor && matchMat && matchCat
            }
            onFilterApplied(filtered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .foregroundColor(.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func getColor(from name: String) -> Color {
        switch name.lowercased() {
            case "red":    return .red
            case "orange": return .orange
            case "yellow": return .yellow
            case "green":  return .green
            case "blue":   return .blue
            case "purple": return .purple
            case "pink":   return .pink
            case "brown":  return .brown
            case "black":  return .black
            case "white":  return .white
            case "gray":   return .gray
            default:        return .gray
        }
    }
}
