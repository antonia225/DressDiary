import UIKit

struct ClothingItem: Identifiable {
    let id: Int
    let category: String
    let color: String
    let materials: [String]
    let subcategory: String
    let image: UIImage

    let pantLength: Double?
    let pantWaist: String?
    let jacketWaterproof: Bool?
    let topSleeveType: String?
    let topNeckline: String?
    let shoeSize: Double?
}

extension ClothingItem {
    init?(dictionary: [String: Any], fallbackId: Int? = nil) {
        guard let resolvedId: Int = {
            if let value = dictionary["id"] as? Int {
                return value
            }
            if let num = dictionary["id"] as? NSNumber {
                return num.intValue
            }
            return fallbackId
        }() else {
            return nil
        }

        let category = dictionary["category"] as? String ?? ""
        let color = dictionary["color"] as? String ?? ""

        let materials: [String]
        if let array = dictionary["materials"] as? [String] {
            materials = array
        } else if let array = dictionary["materials"] as? [NSString] {
            materials = array.map { String($0) }
        } else {
            materials = []
        }

        let resolvedImage: UIImage
        if let data = dictionary["image"] as? Data,
           !data.isEmpty,
           let img = UIImage(data: data) {
            resolvedImage = img
        } else {
            resolvedImage = UIImage()
        }

        func doubleValue(forKey key: String) -> Double? {
            if let value = dictionary[key] as? Double {
                return value
            }
            if let num = dictionary[key] as? NSNumber {
                return num.doubleValue
            }
            if let string = dictionary[key] as? String,
               let value = Double(string.replacingOccurrences(of: ",", with: ".")) {
                return value
            }
            return nil
        }

        func boolValue(forKey key: String) -> Bool? {
            if let value = dictionary[key] as? Bool {
                return value
            }
            if let num = dictionary[key] as? NSNumber {
                return num.boolValue
            }
            return nil
        }

        let pantLength = doubleValue(forKey: "pantLength")
        let pantWaist: String? = {
            if let waist = dictionary["pantWaist"] as? String {
                return waist
            }
            if let num = dictionary["pantWaist"] as? NSNumber {
                return String(format: "%.1f", num.doubleValue)
            }
            return nil
        }()

        let jacketWaterproof = boolValue(forKey: "jacketWaterproof")
        let topSleeveType = dictionary["topSleeveType"] as? String
        let topNeckline = dictionary["topNeckline"] as? String
        let shoeSize = doubleValue(forKey: "shoeSize")
        let subcategory = dictionary["subcategory"] as? String ?? ""

        self = ClothingItem(
            id: resolvedId,
            category: category,
            color: color,
            materials: materials,
            subcategory: subcategory,
            image: resolvedImage,
            pantLength: pantLength,
            pantWaist: pantWaist,
            jacketWaterproof: jacketWaterproof,
            topSleeveType: topSleeveType,
            topNeckline: topNeckline,
            shoeSize: shoeSize
        )
    }
}
