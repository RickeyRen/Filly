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
    var brand: String
    var materialType: String
    
    init(name: String, color: Color, brand: String = "", materialType: String = "") {
        self.name = name
        self.colorData = ColorData(from: color)
        self.lastUsed = Date()
        self.brand = brand
        self.materialType = materialType
    }
    
    init(id: UUID, name: String, colorData: ColorData, lastUsed: Date, brand: String = "", materialType: String = "") {
        self.id = id
        self.name = name
        self.colorData = colorData
        self.lastUsed = lastUsed
        self.brand = brand
        self.materialType = materialType
    }
    
    func getUIColor() -> Color {
        return Color(red: colorData.red, green: colorData.green, blue: colorData.blue, opacity: colorData.alpha)
    }
    
    static func ==(lhs: FilamentColor, rhs: FilamentColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 基础预设颜色
    static let basicPresets: [FilamentColor] = [
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
    
    // 天瑞 PETG-ECO 颜色预设
    static let tianruiPETGColors: [FilamentColor] = [
        FilamentColor(name: "亮丽黄", color: Color(red: 1.0, green: 0.9, blue: 0.2), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "咖啡色", color: Color(red: 0.6, green: 0.4, blue: 0.2), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "透明", color: Color(white: 0.95, opacity: 0.5), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "荧光绿", color: Color(red: 0.4, green: 1.0, blue: 0.4), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "荧光黄", color: Color(red: 1.0, green: 1.0, blue: 0.4), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "红色", color: .red, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "绿色", color: .green, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "灰色", color: .gray, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "杏色", color: Color(red: 0.98, green: 0.84, blue: 0.65), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "黑色", color: .black, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "冷白", color: Color(white: 0.95), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "奶白色", color: Color(red: 1.0, green: 0.98, blue: 0.94), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "米宝白", color: Color(red: 1.0, green: 0.95, blue: 0.9), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "肤色", color: Color(red: 1.0, green: 0.87, blue: 0.73), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "淡灰色", color: Color(white: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "夜光绿", color: Color(red: 0.7, green: 1.0, blue: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "橙色", color: .orange, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "樱花粉", color: Color(red: 1.0, green: 0.7, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "粉色", color: .pink, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "长春花蓝", color: Color(red: 0.0, green: 0.5, blue: 1.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "薄荷绿", color: Color(red: 0.6, green: 1.0, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "卡特黄", color: Color(red: 1.0, green: 0.85, blue: 0.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "天空蓝", color: Color(red: 0.4, green: 0.7, blue: 1.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "橄榄绿", color: Color(red: 0.5, green: 0.6, blue: 0.3), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "透明蓝", color: Color(red: 0.6, green: 0.8, blue: 1.0, opacity: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "透明绿", color: Color(red: 0.6, green: 1.0, blue: 0.8, opacity: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "透明红", color: Color(red: 1.0, green: 0.6, blue: 0.6, opacity: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "荧光玫红", color: Color(red: 1.0, green: 0.4, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "荧光紫红", color: Color(red: 0.8, green: 0.4, blue: 1.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "克莱因蓝", color: Color(red: 0.0, green: 0.2, blue: 0.6), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属紫", color: Color(red: 0.5, green: 0.0, blue: 0.5), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属香槟金", color: Color(red: 0.9, green: 0.8, blue: 0.6), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属午夜绿", color: Color(red: 0.0, green: 0.3, blue: 0.3), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属银", color: Color(red: 0.75, green: 0.75, blue: 0.75), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属太空灰", color: Color(red: 0.5, green: 0.5, blue: 0.55), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属铜", color: Color(red: 0.85, green: 0.53, blue: 0.1), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属绿", color: Color(red: 0.0, green: 0.5, blue: 0.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属珠光蓝", color: Color(red: 0.0, green: 0.5, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "金属玫瑰金", color: Color(red: 0.9, green: 0.6, blue: 0.5), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG碳纤维黑色", color: .black, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG碳纤维大理石灰", color: Color(white: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG碳纤维咖啡色", color: Color(red: 0.55, green: 0.35, blue: 0.15), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "高速Petg薰衣草紫", color: Color(red: 0.7, green: 0.5, blue: 0.9), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "高速Petg桃红", color: Color(red: 1.0, green: 0.4, blue: 0.6), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "高速Petg黑色", color: .black, brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "高速Petg浅蓝", color: Color(red: 0.6, green: 0.8, blue: 1.0), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "高速Petg冷白", color: Color(white: 0.95), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "Petg大理石花岗岩", color: Color(red: 0.7, green: 0.7, blue: 0.7), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "大理石魔幻棕", color: Color(red: 0.65, green: 0.45, blue: 0.25), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "大理石浅灰", color: Color(white: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "大理石白", color: Color(white: 0.9), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG大理石魔幻紫", color: Color(red: 0.6, green: 0.4, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG大理石魔幻蓝", color: Color(red: 0.4, green: 0.5, blue: 0.8), brand: "天瑞 Tinmorry", materialType: "PETG-ECO"),
        FilamentColor(name: "PETG大理石魔幻绿", color: Color(red: 0.4, green: 0.7, blue: 0.5), brand: "天瑞 Tinmorry", materialType: "PETG-ECO")
    ]
    
    // 拓竹 PLA Basic 颜色预设
    static let tinzhuPLABasicColors: [FilamentColor] = [
        FilamentColor(name: "银色10102【含料盘】", color: Color("#C0C0C0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "红色10200【含料盘】", color: Color("#FF0000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "黑色10101【含料盘】", color: Color("#000000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "深蓝色10601【含料盘】", color: Color("#00008B"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "拓竹绿10501【含料盘】", color: Color("#2E8B57"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "金色10401【含料盘】", color: Color("#FFD700"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "青铜色10801【含料盘】", color: Color("#CD7F32"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "紫色10700【含料盘】", color: Color("#800080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "橙色10300【含料盘】", color: Color("#FFA500"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "灰蓝10602【含料盘】", color: Color("#6699CC"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "灰色10103【含料盘】", color: Color("#808080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "棕色10800【含料盘】", color: Color("#8B4513"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "浅杏色10201【含料盘】", color: Color("#FFCC99"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "粉红色10203【含料盘】", color: Color("#FFC0CB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "玉石白10100【含料盘】", color: Color("#F5F5F5"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "黄色10400【含料盘】", color: Color("#FFFF00"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "品红色10202【含料盘】", color: Color("#FF00FF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "青色10603【含料盘】", color: Color("#00FFFF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "圣诞绿10502【含料盘】", color: Color("#006400"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "南瓜橙10301【含料盘】", color: Color("#FF7518"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "暖黄色10402【含料盘】", color: Color("#FFD580"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "绀紫色10701【含料盘】", color: Color("#4B0082"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "桃红色10204【含料盘】", color: Color("#FF69B4"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "可可棕10802【含料盘】", color: Color("#D2691E"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        
        FilamentColor(name: "浅灰10104【无料盘】", color: Color("#D3D3D3"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "深灰10105【无料盘】", color: Color("#696969"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "金色10401【无料盘】", color: Color("#FFD700"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "紫色10700【无料盘】", color: Color("#800080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "品红色10202【无料盘】", color: Color("#FF00FF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "青色10603【无料盘】", color: Color("#00FFFF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "圣诞绿10502【无料盘】", color: Color("#006400"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "青铜色10801【无料盘】", color: Color("#CD7F32"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "可可棕10802【无料盘】", color: Color("#D2691E"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "红色10200【无料盘】", color: Color("#FF0000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "南瓜橙10301【无料盘】", color: Color("#FF7518"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "暖黄色10402【无料盘】", color: Color("#FFD580"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "桃红色10204【无料盘】", color: Color("#FF69B4"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "钴蓝色10604【无料盘】", color: Color("#0047AB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "胭脂红10205【无料盘】", color: Color("#E34234"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "玉石白10100【无料盘】", color: Color("#F5F5F5"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "绀紫色10701【无料盘】", color: Color("#4B0082"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "橙色10300【无料盘】", color: Color("#FFA500"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "深蓝色10601【无料盘】", color: Color("#00008B"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "灰色10103【无料盘】", color: Color("#808080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "浅杏色10201【无料盘】", color: Color("#FFCC99"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "银色10102【无料盘】", color: Color("#C0C0C0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "黄色10400【无料盘】", color: Color("#FFFF00"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "灰蓝10602【无料盘】", color: Color("#6699CC"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "粉红色10203【无料盘】", color: Color("#FFC0CB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "棕色10800【无料盘】", color: Color("#8B4513"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "苹果绿10503【无料盘】", color: Color("#8DB600"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "松石绿10605【无料盘】", color: Color("#40E0D0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "拓竹绿10501【无料盘】", color: Color("#2E8B57"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
        FilamentColor(name: "黑色10101【无料盘】", color: Color("#000000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic")
    ]
    
    // 合并所有预设颜色
    static var presets: [FilamentColor] {
        var allPresets = basicPresets
        allPresets.append(contentsOf: tianruiPETGColors)
        allPresets.append(contentsOf: tinzhuPLABasicColors)
        return allPresets
    }
    
    // 获取所有品牌列表
    static var allBrands: [String] {
        var brands = Set<String>()
        for color in presets {
            if !color.brand.isEmpty {
                brands.insert(color.brand)
            }
        }
        return Array(brands).sorted()
    }
    
    // 获取特定品牌的所有颜色
    static func colorsForBrand(_ brand: String) -> [FilamentColor] {
        return presets.filter { $0.brand == brand }
    }
    
    // 获取所有材料类型
    static var allMaterialTypes: [String] {
        var types = Set<String>()
        for color in presets {
            if !color.materialType.isEmpty {
                types.insert(color.materialType)
            }
        }
        return Array(types).sorted()
    }
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