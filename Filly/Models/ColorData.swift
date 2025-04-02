import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// 由于SwiftUI的Color不符合Codable，我们需要创建一个可编码的颜色数据结构
struct ColorData: Codable {
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
        // 直接使用存储的值，因为已经是0-1范围
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
} 