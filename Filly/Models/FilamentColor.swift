import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct FilamentColor: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var colorData: ColorData
    var lastUsed: Date
    
    init(name: String, color: Color) {
        self.name = name
        self.colorData = ColorData(from: color)
        self.lastUsed = Date()
    }
    
    func getUIColor() -> Color {
        return Color(red: colorData.red, green: colorData.green, blue: colorData.blue, opacity: colorData.alpha)
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
    var alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(from color: Color) {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
        #elseif os(macOS)
        let nsColor = NSColor(color)
        // 确保转换为RGB颜色空间
        if let rgbColor = nsColor.usingColorSpace(.sRGB) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.red = Double(red)
            self.green = Double(green)
            self.blue = Double(blue)
            self.alpha = Double(alpha)
        } else {
            // 如果无法转换，则使用默认值
            self.red = 0.5
            self.green = 0.5
            self.blue = 0.5
            self.alpha = 1.0
        }
        #endif
    }
    
    func getUIColor() -> Color {
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
} 