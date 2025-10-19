import SwiftUI

struct OutfitCard: View {
    let outfit: SavedOutfit
    @State private var isFlipped = false

    var body: some View {
        let card = Group {
            if isFlipped {
                backView
            } else {
                frontView
            }
        }

        card
            .frame(width: 160, height: 220)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("FieldColor"))
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
            )
            .onTapGesture {
                isFlipped.toggle()
            }
    }

    private var frontView: some View {
        VStack(spacing: 0) {
            if outfit.items.isEmpty {
                Image("placeholderCard")
                    .resizable()
                    .scaledToFill()
            } else {
                OutfitPreviewCollage(images: outfit.items.map(\.image))
            }
        }
        .frame(width: 160, height: 220)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var backView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(outfit.name)
                .font(.headline)
                .foregroundColor(Color("textColor"))
                .lineLimit(1)

            Text(outfit.season.capitalized)
                .font(.caption)
                .foregroundColor(Color("captionColor"))
                .lineLimit(1)
            Text("\(outfit.items.count) item(s)")
                .font(.caption2)
                .foregroundColor(Color("captionColor"))

            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color("FieldColor"))
        )
    }
}

private struct OutfitPreviewCollage: View {
    let images: [UIImage]

    var body: some View {
        GeometryReader { geo in
            let limited = Array(images.prefix(4))
            let span = min(geo.size.width, geo.size.height)
            let tileSize = max(span * 0.72, 64)
            let offsets = collageOffsets(for: limited.count, span: span)

            ZStack {
                Color("FieldColor")
                ForEach(Array(limited.enumerated()), id: \.offset) { index, image in
                    tile(for: image)
                        .frame(width: tileSize, height: tileSize)
                        .offset(index < offsets.count ? offsets[index] : .zero)
                        .zIndex(Double(index))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func tile(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

private func collageOffsets(for count: Int, span: CGFloat) -> [CGSize] {
    let shift = span * 0.28
    switch count {
    case 0:
        return []
    case 1:
        return [.zero]
    case 2:
        return [
            CGSize(width: -shift * 0.6, height: 0),
            CGSize(width: shift * 0.6, height: 0)
        ]
    case 3:
        return [
            CGSize(width: -shift * 0.6, height: shift * 0.2),
            CGSize(width: 0, height: -shift * 0.45),
            CGSize(width: shift * 0.6, height: shift * 0.2)
        ]
    default:
        return [
            CGSize(width: -shift * 0.7, height: -shift * 0.35),
            CGSize(width: shift * 0.7, height: -shift * 0.35),
            CGSize(width: -shift * 0.35, height: shift * 0.6),
            CGSize(width: shift * 0.35, height: shift * 0.6)
        ]
    }
}
