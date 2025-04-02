import Foundation
import SwiftUI

struct Filament: Identifiable, Codable {
    var id = UUID()
    var brand: String
    var type: FilamentType
    var color: String // 颜色名称
    var colorData: ColorData? // 颜色数据
    var weight: Double // 以克为单位
    var diameter: FilamentDiameter
    var spools: [FilamentSpool] // 耗材盘数组
    var dateAdded: Date
    var notes: String
    
    // 自定义初始化方法
    init(brand: String, type: FilamentType, color: String, 
         colorData: ColorData? = nil,
         weight: Double = 1000, diameter: FilamentDiameter = .mm175, 
         spools: [FilamentSpool] = [FilamentSpool()], notes: String = "") {
        self.brand = brand
        self.type = type
        self.color = color
        self.colorData = colorData
        self.weight = weight
        self.diameter = diameter
        self.spools = spools
        self.dateAdded = Date()
        self.notes = notes
    }
    
    // 获取平均剩余百分比（为了兼容旧代码）
    var remainingPercentage: Double {
        if spools.isEmpty {
            return 0
        }
        return spools.reduce(0) { $0 + $1.remainingPercentage } / Double(spools.count)
    }
    
    // 获取剩余盘数
    var remainingSpoolCount: Int {
        return spools.filter { $0.remainingPercentage > 0 }.count
    }
    
    // 获取满盘数量（100%）
    var fullSpoolCount: Int {
        return spools.filter { $0.remainingPercentage >= 100 }.count
    }
    
    // 获取颜色对象
    func getColor() -> Color {
        if let colorData = colorData {
            return colorData.getUIColor()
        } else {
            // 返回默认颜色映射
            return getDefaultColor(for: color)
        }
    }
    
    // 默认颜色映射
    private func getDefaultColor(for name: String) -> Color {
        let lowerName = name.lowercased()
        
        if lowerName.contains("黑") || lowerName.contains("black") {
            return .black
        } else if lowerName.contains("白") || lowerName.contains("white") {
            return .white
        } else if lowerName.contains("红") || lowerName.contains("red") {
            return .red
        } else if lowerName.contains("蓝") || lowerName.contains("blue") {
            return .blue
        } else if lowerName.contains("绿") || lowerName.contains("green") {
            return .green
        } else if lowerName.contains("黄") || lowerName.contains("yellow") {
            return .yellow
        } else if lowerName.contains("紫") || lowerName.contains("purple") {
            return .purple
        } else if lowerName.contains("橙") || lowerName.contains("orange") {
            return .orange
        } else if lowerName.contains("灰") || lowerName.contains("gray") {
            return .gray
        } else if lowerName.contains("透明") || lowerName.contains("clear") {
            return Color(white: 0.9, opacity: 0.5)
        } else {
            return .gray
        }
    }
}

// 耗材类型
enum FilamentType: String, Codable, CaseIterable, Identifiable {
    case pla = "PLA"
    case plaLite = "PLA Lite"
    case abs = "ABS"
    case petg = "PETG"
    case tpu = "TPU"
    case pc = "PC"
    case asa = "ASA"
    case pva = "PVA"
    case hips = "HIPS"
    case nylon = "尼龙"
    case other = "其他"
    
    var id: String { self.rawValue }
}

// 耗材直径
enum FilamentDiameter: Double, Codable, CaseIterable, Identifiable {
    case mm175 = 1.75
    case mm285 = 2.85
    case mm30 = 3.0
    
    var id: Double { self.rawValue }
    
    var description: String {
        return "\(self.rawValue)mm"
    }
}

// 预设品牌
struct PresetBrands {
    static let brands = [
        "拓竹 Bambu Lab",
        "天瑞 Tinmorry",
        "普维 Polymaker",
        "易生 eSUN",
        "Creality",
        "Prusa",
        "Sunlu",
        "思普瑞 Raise3D",
        "IEMAI"
    ]
} 