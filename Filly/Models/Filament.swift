import Foundation

struct Filament: Identifiable, Codable {
    var id = UUID()
    var brand: String
    var type: FilamentType
    var color: String
    var weight: Double // 以克为单位
    var diameter: FilamentDiameter
    var remainingPercentage: Double // 剩余百分比（0-100）
    var notes: String
    var dateAdded: Date
    
    // 自定义初始化方法
    init(brand: String, type: FilamentType, color: String, 
         weight: Double = 1000, diameter: FilamentDiameter = .mm175, 
         remainingPercentage: Double = 100, notes: String = "") {
        self.brand = brand
        self.type = type
        self.color = color
        self.weight = weight
        self.diameter = diameter
        self.remainingPercentage = remainingPercentage
        self.notes = notes
        self.dateAdded = Date()
    }
}

// 耗材类型
enum FilamentType: String, Codable, CaseIterable, Identifiable {
    case pla = "PLA"
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
        "Bambu Lab",
        "天瑞 Tianrui",
        "普维 Polymaker",
        "易生 eSUN",
        "Creality",
        "Prusa",
        "Sunlu",
        "思普瑞 Raise3D",
        "IEMAI"
    ]
} 