import SwiftUI

struct FilamentColor: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var color: ColorData
    var lastUsed: Date
    
    init(name: String, color: Color) {
        self.name = name
        self.color = ColorData(from: color)
        self.lastUsed = Date()
    }
    
    func toColor() -> Color {
        return color.toColor()
    }
    
    static func ==(lhs: FilamentColor, rhs: FilamentColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 预设颜色
    static let presets: [FilamentColor] = [
        FilamentColor(name: "黑色", color: .black),
        FilamentColor(name: "白色", color: .white),
        FilamentColor(name: "红色", color: .red),
        FilamentColor(name: "蓝色", color: .blue),
        FilamentColor(name: "绿色", color: .green),
        FilamentColor(name: "黄色", color: .yellow),
        FilamentColor(name: "橙色", color: .orange),
        FilamentColor(name: "紫色", color: .purple),
        FilamentColor(name: "粉色", color: .pink),
        FilamentColor(name: "灰色", color: .gray),
        FilamentColor(name: "透明", color: Color(white: 0.9, opacity: 0.5))
    ]
}

// 由于SwiftUI的Color不符合Codable，我们需要创建一个可编码的颜色数据结构
struct ColorData: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
    
    init(from color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        let uiColor = UIColor(color)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.opacity = Double(opacity)
    }
    
    func toColor() -> Color {
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
} 