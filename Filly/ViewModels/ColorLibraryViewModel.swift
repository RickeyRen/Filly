import SwiftUI
import Combine

class ColorLibraryViewModel: ObservableObject {
    @Published var colors: [FilamentColor] = []
    @Published var selectedBrand: String = ""
    @Published var selectedMaterialType: String = ""
    
    private let saveKey = "savedColors"
    
    init() {
        // 加载颜色
        loadColors()
        
        // 如果颜色列表为空，添加所有预设颜色
        if colors.isEmpty {
            addAllPredefinedColors()
        }
        
        // 确保拓竹品牌的颜色在列表中
        ensureTinzhuColorsExist()
    }
    
    // 添加所有预设颜色
    func addAllPredefinedColors() {
        colors = FilamentColor.presets
        saveColors()
    }
    
    // 确保拓竹颜色存在
    private func ensureTinzhuColorsExist() {
        // 检查是否已经存在拓竹的颜色
        let hasTinzhuColors = colors.contains { $0.brand == "拓竹 Bambu Lab" }
        
        // 如果没有拓竹颜色，添加它们
        if !hasTinzhuColors {
            addColors(FilamentColor.tinzhuPLABasicColors)
        }
    }
    
    // 添加拓竹 PLA Lite 所有颜色
    func addAllTinzhuPLALiteColors() {
        let tinzhuPLALiteColors: [FilamentColor] = [
            FilamentColor(name: "黑色 16100 【无料盘】", color: Color.black, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "天蓝色 16600【无料盘】", color: Color(red: 0.53, green: 0.81, blue: 0.98), brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "黄色 16400【无料盘】", color: Color.yellow, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "白色 16103【无料盘】", color: Color.white, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "红色 16200【无料盘】", color: Color.red, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "灰色 16101【无料盘】", color: Color.gray, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            
            FilamentColor(name: "黑色 16100 【含料盘】", color: Color.black, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "天蓝色 16600【含料盘】", color: Color(red: 0.53, green: 0.81, blue: 0.98), brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "黄色 16400【含料盘】", color: Color.yellow, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "红色 16200【含料盘】", color: Color.red, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "白色 16103【含料盘】", color: Color.white, brand: "拓竹 Bambu Lab", materialType: "PLA Lite"),
            FilamentColor(name: "灰色 16101【含料盘】", color: Color.gray, brand: "拓竹 Bambu Lab", materialType: "PLA Lite")
        ]
        
        // 添加颜色到库中
        addColors(tinzhuPLALiteColors)
    }
    
    // 添加新颜色
    func addColor(_ color: FilamentColor) {
        // 检查是否已存在相同名称的颜色
        if let index = colors.firstIndex(where: { $0.name.lowercased() == color.name.lowercased() }) {
            // 更新现有颜色
            colors[index] = color
        } else {
            // 添加新颜色
            colors.append(color)
        }
        
        saveColors()
    }
    
    // 批量添加颜色
    func addColors(_ newColors: [FilamentColor]) {
        for color in newColors {
            addColor(color)
        }
    }
    
    // 更新颜色的最后使用时间
    func updateLastUsed(for color: FilamentColor) {
        if let index = colors.firstIndex(where: { $0.id == color.id }) {
            var updatedColor = colors[index]
            updatedColor.lastUsed = Date()
            colors[index] = updatedColor
            saveColors()
        }
    }
    
    // 删除颜色
    func deleteColor(at offsets: IndexSet) {
        // 确保不会删除所有预设颜色
        let canDeleteAll = !offsets.contains { colors[$0].name == "黑色" && colors[$0].name == "白色" }
        
        if canDeleteAll || colors.count > offsets.count {
            colors.remove(atOffsets: offsets)
            saveColors()
        }
    }
    
    // 删除指定ID的颜色
    func deleteColor(id: UUID) {
        if let index = colors.firstIndex(where: { $0.id == id }) {
            colors.remove(at: index)
            saveColors()
        }
    }
    
    // 最近使用的颜色（按最后使用时间排序）
    func recentlyUsedColors(limit: Int = 5) -> [FilamentColor] {
        return colors.sorted { $0.lastUsed > $1.lastUsed }.prefix(limit).map { $0 }
    }
    
    // 根据名称搜索颜色
    func searchColors(query: String) -> [FilamentColor] {
        if query.isEmpty {
            return filteredColors()
        }
        
        return filteredColors().filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    // 获取所有可用的品牌
    var availableBrands: [String] {
        var brands = Set<String>()
        for color in colors {
            if !color.brand.isEmpty {
                brands.insert(color.brand)
            }
        }
        return Array(brands).sorted()
    }
    
    // 获取所有可用的材料类型
    var availableMaterialTypes: [String] {
        var types = Set<String>()
        
        // 如果选择了品牌，只返回该品牌下的材料类型
        if !selectedBrand.isEmpty {
            for color in colors {
                if color.brand == selectedBrand && !color.materialType.isEmpty {
                    types.insert(color.materialType)
                }
            }
        } else {
            // 如果没有选择品牌，返回所有材料类型
            for color in colors {
                if !color.materialType.isEmpty {
                    types.insert(color.materialType)
                }
            }
        }
        
        return Array(types).sorted()
    }
    
    // 根据所选品牌和材料类型过滤颜色
    func filteredColors() -> [FilamentColor] {
        var filteredColors = colors
        
        if !selectedBrand.isEmpty {
            filteredColors = filteredColors.filter { $0.brand == selectedBrand }
        }
        
        if !selectedMaterialType.isEmpty {
            filteredColors = filteredColors.filter { $0.materialType == selectedMaterialType }
        }
        
        return filteredColors
    }
    
    // 根据品牌获取颜色
    func colorsForBrand(_ brand: String) -> [FilamentColor] {
        return colors.filter { $0.brand == brand }
    }
    
    // 根据材料类型获取颜色
    func colorsForMaterialType(_ materialType: String) -> [FilamentColor] {
        return colors.filter { $0.materialType == materialType }
    }
    
    // 重置所有颜色为预设颜色
    func resetToDefaults() {
        colors = FilamentColor.presets
        saveColors()
    }
    
    // 添加特定品牌的所有颜色
    func addAllColorsForBrand(_ brand: String) {
        let brandColors = FilamentColor.colorsForBrand(brand)
        addColors(brandColors)
    }
    
    // 保存颜色库
    func saveColors() {
        if let encoded = try? JSONEncoder().encode(colors) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 加载颜色库
    private func loadColors() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([FilamentColor].self, from: data) {
            colors = decoded
        }
    }
} 