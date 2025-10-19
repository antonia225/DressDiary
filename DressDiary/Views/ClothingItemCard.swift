import SwiftUI

struct ClothingItemCard: View {
    let item: ClothingItem
    @State private var isFlipped = false

    var body: some View {
        Group {
            if isFlipped {
                backView
            } else {
                frontView
            }
        }
        .frame(width: 160, height: 210)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("FieldColor"))
                .shadow(color: Color.black.opacity(0.20), radius: 6, x: 0, y: 4)
        )
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    private var frontView: some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 210)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var backView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(Color("textColor"))

            Spacer()
            
            ForEach(Array(detailRows.enumerated()), id: \.offset) { _, detail in HStack(alignment: .top, spacing: 6) {
                Text(detail.label)
                    .font(.footnote)
                    .foregroundColor(Color("textColor"))
                Spacer(minLength: 4)
                Text(detail.value)
                    .font(.footnote)
                    .foregroundColor(Color("textColor"))
                    .multilineTextAlignment(.trailing)
                }
            }
            
            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("FieldColor"))
        )
    }

    private var detailRows: [(label: String, value: String)] {
        var rows: [(String, String)] = []

        if !item.materials.isEmpty {
            rows.append(("Materials", item.materials.joined(separator: ", ")))
        }

        switch item.category.lowercased() {
        case "pants":
            if let length = item.pantLength {
                rows.append(("Length", formatNumber(length)))
            }
            if let waist = item.pantWaist, !waist.isEmpty {
                rows.append(("Waist", waist))
            }
        case "jacket":
            if let waterproof = item.jacketWaterproof {
                rows.append(("Waterproof", waterproof ? "Yes" : "No"))
            }
        case "top":
            if let sleeve = item.topSleeveType, !sleeve.isEmpty {
                rows.append(("Sleeve", sleeve))
            }
            if let neckline = item.topNeckline, !neckline.isEmpty {
                rows.append(("Neckline", neckline))
            }
        case "shoes":
            if let shoeSize = item.shoeSize {
                rows.append(("Shoe Size", formatNumber(shoeSize)))
            }
        default:
            break
        }

        return rows
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }
}
