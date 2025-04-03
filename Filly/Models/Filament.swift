import Foundation
import SwiftUI

// 新的耗材类型模型 - 替代枚举
struct FilamentTypeModel: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    
    // 初始化方法
    init(name: String) {
        self.name = name
    }
    
    // 便于与旧枚举进行转换的静态方法
    static func from(_ legacyType: FilamentType) -> FilamentTypeModel {
        return FilamentTypeModel(name: legacyType.rawValue)
    }
    
    // 用于比较
    static func == (lhs: FilamentTypeModel, rhs: FilamentTypeModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    // 用于 Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

struct Filament: Identifiable, Codable {
    var id = UUID()
    var brand: String
    var type: FilamentTypeModel // 修改为使用 FilamentTypeModel 而非枚举
    var color: String // 颜色名称
    var colorData: ColorData? // 颜色数据
    var weight: Double // 以克为单位
    var diameter: FilamentDiameter
    var spools: [FilamentSpool] // 耗材盘数组
    var dateAdded: Date
    var notes: String
    
    // 自定义初始化方法
    init(brand: String, type: FilamentTypeModel, color: String, 
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
    
    // 向后兼容的初始化方法（使用旧 FilamentType 枚举）
    init(brand: String, type: FilamentType, color: String,
         colorData: ColorData? = nil,
         weight: Double = 1000, diameter: FilamentDiameter = .mm175,
         spools: [FilamentSpool] = [FilamentSpool()], notes: String = "") {
        self.brand = brand
        self.type = FilamentTypeModel.from(type) // 转换枚举为模型
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
    
    // 获取颜色对象 - 如果是单一颜色则返回，否则返回第一个颜色
    func getColor() -> Color {
        let colors = getGradientColors()
        return colors.first ?? getDefaultColor(for: color) // 如果无法解析，返回默认颜色
    }

    // 获取渐变颜色数组
    func getGradientColors() -> [Color] {
        // 特殊处理彩虹色
        if color.lowercased() == "rainbow" || color == "彩虹色" {
            return [
                .red, .orange, .yellow, .green, .blue, .indigo, .purple
            ]
        }
        
        // 尝试解析以'-'分隔的颜色字符串
        let colorComponents = color.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // 如果只有一个组件或无法解析，则返回单一颜色数组
        if colorComponents.count <= 1 {
            if let colorData = colorData {
                return [colorData.getUIColor()]
            } else {
                return [getDefaultColor(for: color)]
            }
        }
        
        // 尝试将每个组件解析为颜色
        let colors: [Color] = colorComponents.compactMap { component in
            // 优先尝试解析十六进制颜色
            if component.starts(with: "#"), let uiColor = UIColor(hexString: component) {
                return Color(uiColor)
            } else {
                // 否则，使用默认颜色映射
                return getDefaultColor(for: component)
            }
        }
        
        // 如果成功解析出多种颜色，则返回颜色数组
        return colors.count > 1 ? colors : [getColor()] // 如果解析后仍为单一颜色，则返回单一颜色数组
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
        } else if lowerName.contains("银") || lowerName.contains("silver") {
            return Color(red: 192/255, green: 192/255, blue: 192/255)
        } else if lowerName.contains("金") || lowerName.contains("gold") {
            return Color(red: 255/255, green: 215/255, blue: 0/255)
        } else if lowerName.contains("透明") || lowerName.contains("clear") {
            return Color(white: 0.9, opacity: 0.5)
        } else {
            // 尝试随机生成颜色基于字符串哈希值 - 保持颜色一致性
            var hash = 0
            for char in lowerName.unicodeScalars {
                hash = 31 &* hash &+ Int(char.value)
            }
            let random = RandomNumberGeneratorWithSeed(seed: UInt64(abs(hash)))
            return Color(
                red: Double.random(in: 0.2...0.8, using: &random),
                green: Double.random(in: 0.2...0.8, using: &random),
                blue: Double.random(in: 0.2...0.8, using: &random)
            )
        }
    }
}

// 旧的耗材类型枚举 - 保留用于向后兼容和转换
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

// 添加UIColor扩展以支持十六进制字符串
extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
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
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// 添加随机数生成器以确保基于名称的颜色一致性
struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    var seed: UInt64
    
    init(seed: UInt64) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        seed = seed &* 1103515245 &+ 12345
        return seed
    }
} 