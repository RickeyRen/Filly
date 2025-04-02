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
    
    // 新增渐变相关字段
    @DefaultValue(0) var gradientType: Int // 使用Int而非enum以便SwiftData兼容，0=none, 1=horizontal, 2=vertical等
    var additionalColorsData: [SwiftDataColorData]? // 其他颜色（用于渐变）
    
    // Relationship to MaterialType
    var materialType: SwiftDataMaterialType?
    
    init(id: UUID = UUID(), name: String, code: String? = nil, colorData: SwiftDataColorData,
         isTransparent: Bool = false, isMetallic: Bool = false, hasSpool: Bool = false,
         gradientType: Int = 0, additionalColorsData: [SwiftDataColorData]? = nil,
         materialType: SwiftDataMaterialType? = nil) {
        self.id = id
        self.name = name
        self.code = code
        self.colorData = colorData
        self.isTransparent = isTransparent
        self.isMetallic = isMetallic
        self.hasSpool = hasSpool
        self.gradientType = gradientType
        self.additionalColorsData = additionalColorsData
        self.materialType = materialType
    }
    
    // Helper to get the base color name without spool info
    var baseColorName: String {
        return name.replacingOccurrences(of: " (含料盘)", with: "")
                   .replacingOccurrences(of: " (无料盘)", with: "")
    }
    
    // 帮助函数：判断是否是渐变色
    var isGradient: Bool {
        return gradientType > 0 && (additionalColorsData?.isEmpty == false)
    }
    
    // 帮助函数：获取完整的渐变（如果有）
    func getGradient() -> Gradient? {
        guard isGradient, let additionalColors = additionalColorsData else {
            return nil
        }
        
        // 将主色和附加色合并为一个渐变数组
        var colors: [Color] = [colorData.toColor()]
        colors.append(contentsOf: additionalColors.map { $0.toColor() })
        
        // 创建渐变
        return Gradient(colors: colors)
    }
}

// Codable struct for Color data compatible with SwiftData
struct SwiftDataColorData: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        // 检查输入的颜色值范围，确保存储为0-1范围
        self.red = red > 1.0 ? red / 255.0 : red
        self.green = green > 1.0 ? green / 255.0 : green
        self.blue = blue > 1.0 ? blue / 255.0 : blue
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