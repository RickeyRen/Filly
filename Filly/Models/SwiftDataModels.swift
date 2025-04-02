import Foundation
import SwiftUI
import SwiftData

// MARK: - SwiftData Models for Consumable Library

@Model
final class SwiftDataBrand {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataMaterialType.brand)
    var materialTypes: [SwiftDataMaterialType]
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.materialTypes = []
    }
}

@Model
final class SwiftDataMaterialType {
    @Attribute(.unique) var id: UUID
    var name: String
    var properties: String?  // Optional properties like print temp, etc.
    
    // Relationship to Brand
    var brand: SwiftDataBrand?
    
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataFilamentColor.materialType)
    var colors: [SwiftDataFilamentColor]
    
    init(id: UUID = UUID(), name: String, properties: String? = nil, brand: SwiftDataBrand? = nil) {
        self.id = id
        self.name = name
        self.properties = properties
        self.brand = brand
        self.colors = []
    }
}

@Model
final class SwiftDataFilamentColor {
    @Attribute(.unique) var id: UUID
    var name: String // e.g., "黑色 (含料盘)"
    var code: String? // Product code like "16100"
    var colorData: SwiftDataColorData
    var isTransparent: Bool
    var isMetallic: Bool
    var hasSpool: Bool // To distinguish spool/no-spool variants
    
    // Relationship to MaterialType
    var materialType: SwiftDataMaterialType?
    
    init(id: UUID = UUID(), name: String, code: String? = nil, colorData: SwiftDataColorData,
         isTransparent: Bool = false, isMetallic: Bool = false, hasSpool: Bool = false,
         materialType: SwiftDataMaterialType? = nil) {
        self.id = id
        self.name = name
        self.code = code
        self.colorData = colorData
        self.isTransparent = isTransparent
        self.isMetallic = isMetallic
        self.hasSpool = hasSpool
        self.materialType = materialType
    }
    
    // Helper to get the base color name without spool info
    var baseColorName: String {
        return name.replacingOccurrences(of: " (含料盘)", with: "")
                   .replacingOccurrences(of: " (无料盘)", with: "")
    }
}

// Codable struct for Color data compatible with SwiftData
struct SwiftDataColorData: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red / 255.0 // Store as 0-1 range
        self.green = green / 255.0
        self.blue = blue / 255.0
        self.alpha = alpha
    }
    
    // Create from SwiftUI Color
    init(from color: Color) {
        #if os(iOS)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
        #elseif os(macOS)
        // Ensure conversion to sRGB color space on macOS
        if let nsColor = NSColor(color).usingColorSpace(.sRGB) {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.alpha = Double(a)
        } else {
            // Fallback if conversion fails
            self.red = 0.5; self.green = 0.5; self.blue = 0.5; self.alpha = 1.0
        }
        #endif
    }
    
    // Convert back to SwiftUI Color
    func toColor() -> Color {
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// Helper function to map color names to default SwiftUI Colors (used for initialization)
func colorMapping(for colorName: String) -> Color {
    let lowerName = colorName.lowercased()
    if lowerName.contains("黑") { return .black }
    if lowerName.contains("白") { return .white }
    if lowerName.contains("红") { return .red }
    if lowerName.contains("天蓝") { return Color(red: 135/255, green: 206/255, blue: 235/255) } // Sky Blue
    if lowerName.contains("蓝") { return .blue }
    if lowerName.contains("黄") { return .yellow }
    if lowerName.contains("绿") { return .green }
    if lowerName.contains("灰") { return .gray }
    if lowerName.contains("橙") { return .orange }
    if lowerName.contains("紫") { return .purple }
    if lowerName.contains("粉") { return .pink }
    if lowerName.contains("透明") { return Color(white: 0.9, opacity: 0.5) }
    return .gray // Default fallback
} 