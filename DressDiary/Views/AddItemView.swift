import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) private var presentation
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var color: String = ""
    @State private var materials: String = ""
    @State private var selectedBase: Int = 0
    @State private var pantsLength: String = ""
    @State private var pantsWaist: String = ""
    @State private var jacketWaterproof: Bool = false
    @State private var topSleeve: String = ""
    @State private var topNeck: String = ""
    @State private var shoeSize: String = ""
    @State private var image: UIImage? = nil
    @State private var showPicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    private let categories = ["pants", "jacket", "top", "shoes"]
    private let colors = ["red","orange","yellow","green","blue","purple","pink","brown","black","white","gray","other"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                colorSection

                TextField("Materials (comma-separated)", text: $materials)
                    .padding()
                    .background(Color("FieldColor"))
                    .cornerRadius(8)
                    .foregroundColor(Color("textColor"))

                Picker(selection: $selectedBase) {
                    Text("Pants").tag(0)
                    Text("Jacket").tag(1)
                    Text("Top").tag(2)
                    Text("Shoes").tag(3)
                } label: {
                    HStack {
                        Text("Category")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(Color("FieldColor"))
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("FieldColor"), lineWidth: 1)
                    )
                }
                .pickerStyle(.segmented)

                Group {
                    switch selectedBase {
                    case 0:
                        TextField("Pants Length", text: $pantsLength)
                            .keyboardType(.decimalPad)
                        TextField("Pants Waist", text: $pantsWaist)
                            .keyboardType(.default)
                    case 1:
                        Toggle("Waterproof", isOn: $jacketWaterproof)
                    case 2:
                        TextField("Sleeve Type", text: $topSleeve)
                        TextField("Neckline Type", text: $topNeck)
                    case 3:
                        TextField("Shoe size", text: $shoeSize)
                            .keyboardType(.decimalPad)
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .background(Color("FieldColor"))
                .cornerRadius(8)
                .foregroundColor(Color("textColor"))

                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color("FieldColor"))
                        .frame(height: 120)
                        .cornerRadius(8)
                }

                Button("Select Image") {
                    showPicker = true
                }
                .foregroundColor(Color("textColor"))
                .sheet(isPresented: $showPicker) {
                    ImagePicker(image: $image)
                }

                Button("Save Item") {
                    save()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(8)
                .foregroundColor(Color("textColor"))

                Button("Cancel") {
                    presentation.wrappedValue.dismiss()
                }
                .foregroundColor(Color("textColor"))
            }
            .padding(32)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private var currentCategory: String {
        categories[selectedBase]
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Colors")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(colors, id: \.self) { colorOption in
                    let fillColor = getColor(from: colorOption)

                    Circle()
                        .fill(fillColor)
                        .overlay(
                            Circle()
                                .stroke(Color("FieldColor"), lineWidth: color == colorOption ? 3 : 1)
                        )
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            color = colorOption
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private func getColor(from name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "black": return .black
        case "white": return .white
        case "gray": return .gray
        default: return .gray
        }
    }

    private func save() {
        guard let user = currentUsername,
              !color.isEmpty,
              !materials.isEmpty,
              let img = image,
              let data = img.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Complete fields and select an image"
            showAlert = true
            return
        }
        let mats = materials.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        let cat = categories[selectedBase]
        let waistValue = pantsWaist.trimmingCharacters(in: .whitespaces)
        let sleeveValue = topSleeve.trimmingCharacters(in: .whitespaces)
        let neckValue = topNeck.trimmingCharacters(in: .whitespaces)
        let success = CppBridge.saveClothingItem(
            forUser: user,
            color: color,
            materials: mats,
            category: cat,
            pantLength: Float(pantsLength) ?? 0,
            pantWaist: waistValue.isEmpty ? nil : waistValue,
            jacketWaterproof: jacketWaterproof,
            topSleeveType: sleeveValue.isEmpty ? nil : sleeveValue,
            topNeckline: neckValue.isEmpty ? nil : neckValue,
            shoeSize: Float(shoeSize) ?? 0,
            image: data
        )
        if success {
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to save"
            showAlert = true
        }
    }
}
