import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Color 扩展，提供更多颜色处理功能
extension Color {
    // 从十六进制字符串创建颜色，更加可靠
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128) // 默认灰色
        }

        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        let alpha = Double(a) / 255.0
        
        #if DEBUG
        print("颜色十六进制转换 \(hex): RGB(\(red), \(green), \(blue))")
        #endif
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // 使用更可靠的方式从SwiftUI Color获取RGB值
    public func getRGBComponents() -> (red: Double, green: Double, blue: Double, alpha: Double) {
        #if os(iOS)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (Double(red), Double(green), Double(blue), Double(alpha))
        } else {
            // 尝试使用HSB模式获取颜色
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            
            if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                // 将HSB转换为RGB
                let c = brightness * saturation
                let x = c * (1 - abs(fmod(hue * 6, 2) - 1))
                let m = brightness - c
                
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                
                if hue < 1/6 {
                    r = c; g = x; b = 0
                } else if hue < 2/6 {
                    r = x; g = c; b = 0
                } else if hue < 3/6 {
                    r = 0; g = c; b = x
                } else if hue < 4/6 {
                    r = 0; g = x; b = c
                } else if hue < 5/6 {
                    r = x; g = 0; b = c
                } else {
                    r = c; g = 0; b = x
                }
                
                return (Double(r + m), Double(g + m), Double(b + m), Double(alpha))
            }
        }
        
        // 默认返回中等灰色
        return (0.5, 0.5, 0.5, 1.0)
        
        #elseif os(macOS)
        let nsColor = NSColor(self)
        
        // 确保使用正确的颜色空间
        if let rgbColor = nsColor.usingColorSpace(.sRGB) {
            return (Double(rgbColor.redComponent), 
                    Double(rgbColor.greenComponent), 
                    Double(rgbColor.blueComponent), 
                    Double(rgbColor.alphaComponent))
        }
        
        // 默认返回中等灰色
        return (0.5, 0.5, 0.5, 1.0)
        #endif
    }
    
    // 更可靠的颜色亮度计算
    public var brightness: Double {
        let components = self.getRGBComponents()
        return (0.299 * components.red + 0.587 * components.green + 0.114 * components.blue)
    }
    
    // 更明亮的颜色
    public func lighter(by amount: CGFloat = 0.2) -> Color {
        let components = self.getRGBComponents()
        return Color(red: min(1.0, components.red + amount), 
                     green: min(1.0, components.green + amount), 
                     blue: min(1.0, components.blue + amount), 
                     opacity: components.alpha)
    }
    
    // 更暗的颜色
    public func darker(by amount: CGFloat = 0.2) -> Color {
        let components = self.getRGBComponents()
        return Color(red: max(0.0, components.red - amount), 
                     green: max(0.0, components.green - amount), 
                     blue: max(0.0, components.blue - amount), 
                     opacity: components.alpha)
    }
}

// FilamentColor 的扩展，添加更多颜色处理能力
extension FilamentColor {
    // 获取更准确的UI颜色表示
    func getAccurateUIColor() -> Color {
        let color = Color(red: colorData.red, green: colorData.green, blue: colorData.blue, opacity: colorData.alpha)
        return color
    }
    
    // 颜色亮度分析
    var isBright: Bool {
        let brightness = 0.299 * colorData.red + 0.587 * colorData.green + 0.114 * colorData.blue
        return brightness > 0.5
    }
    
    // 获取颜色的对比色
    func getContrastColor() -> Color {
        return isBright ? Color.black : Color.white
    }
    
    // 获取更亮的颜色版本
    func getLighterColor(by amount: CGFloat = 0.2) -> Color {
        return Color(red: min(1.0, colorData.red + Double(amount)), 
                     green: min(1.0, colorData.green + Double(amount)), 
                     blue: min(1.0, colorData.blue + Double(amount)), 
                     opacity: colorData.alpha)
    }
    
    // 获取更暗的颜色版本
    func getDarkerColor(by amount: CGFloat = 0.2) -> Color {
        return Color(red: max(0.0, colorData.red - Double(amount)), 
                     green: max(0.0, colorData.green - Double(amount)), 
                     blue: max(0.0, colorData.blue - Double(amount)), 
                     opacity: colorData.alpha)
    }
} 