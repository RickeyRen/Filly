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
        
        // 确保所有品牌的颜色在列表中
        ensureAllBrandColorsExist()
    }
    
    // 添加所有预设颜色
    func addAllPredefinedColors() {
        if colors.isEmpty {
            // 添加预设颜色到颜色库
            for color in FilamentColor.presets {
                addColor(color)
            }
        }
    }
    
    // 确保所有品牌的颜色都存在
    private func ensureAllBrandColorsExist() {
        // 检查是否已经存在拓竹的颜色
        let hasTinzhuBasicColors = colors.contains { $0.brand == "拓竹 Bambu Lab" && $0.materialType == "PLA Basic" }
        let hasTinzhuLiteColors = colors.contains { $0.brand == "拓竹 Bambu Lab" && $0.materialType == "PLA Lite" }
        let hasTinmorryColors = colors.contains { $0.brand == "天瑞 Tinmorry" }
        
        // 如果没有拓竹PLA Basic颜色，添加它们
        if !hasTinzhuBasicColors {
            addAllTinzhuPLABasicColors()
        }
        
        // 如果没有拓竹PLA Lite颜色，添加它们
        if !hasTinzhuLiteColors {
            addAllTinzhuPLALiteColors()
        }
        
        // 如果没有天瑞颜色，添加它们
        if !hasTinmorryColors && FilamentColor.tianruiPETGColors.count > 0 {
            addColors(FilamentColor.tianruiPETGColors)
        }
    }
    
    // 添加拓竹 PLA Lite 所有颜色
    func addAllTinzhuPLALiteColors() {
        // 添加 拓竹 PLA Lite 颜色
        let plaliteColors = [
            ("幻彩蓝 50600【含料盘】", Color(red: 0.0, green: 0.5, blue: 1.0)),
            ("幻彩绿 50500【含料盘】", Color(red: 0.0, green: 0.8, blue: 0.4)),
            ("幻彩红 50200【含料盘】", Color(red: 1.0, green: 0.2, blue: 0.2)),
            ("幻彩橙 50300【含料盘】", Color(red: 1.0, green: 0.6, blue: 0.0)),
            ("幻彩黄 50400【含料盘】", Color(red: 1.0, green: 0.9, blue: 0.0)),
            ("幻彩紫 50700【含料盘】", Color(red: 0.7, green: 0.1, blue: 0.9)),
            ("幻彩粉 50201【含料盘】", Color(red: 1.0, green: 0.4, blue: 0.8)),
            ("幻彩银 50100【含料盘】", Color(red: 0.8, green: 0.8, blue: 0.8)),
            
            ("幻彩蓝 50600【无料盘】", Color(red: 0.0, green: 0.5, blue: 1.0)),
            ("幻彩绿 50500【无料盘】", Color(red: 0.0, green: 0.8, blue: 0.4)),
            ("幻彩红 50200【无料盘】", Color(red: 1.0, green: 0.2, blue: 0.2)),
            ("幻彩橙 50300【无料盘】", Color(red: 1.0, green: 0.6, blue: 0.0)),
            ("幻彩黄 50400【无料盘】", Color(red: 1.0, green: 0.9, blue: 0.0)),
            ("幻彩紫 50700【无料盘】", Color(red: 0.7, green: 0.1, blue: 0.9)),
            ("幻彩粉 50201【无料盘】", Color(red: 1.0, green: 0.4, blue: 0.8)),
            ("幻彩银 50100【无料盘】", Color(red: 0.8, green: 0.8, blue: 0.8))
        ]
        
        for (name, color) in plaliteColors {
            // 检查颜色是否已存在
            let exists = colors.contains { $0.name == name && $0.brand == "拓竹 Bambu Lab" && $0.materialType == "PLA Lite" }
            if !exists {
                let filamentColor = FilamentColor(name: name, color: color, brand: "拓竹 Bambu Lab", materialType: "PLA Lite")
                addColor(filamentColor)
            }
        }
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
        colors = []
        for color in FilamentColor.presets {
            colors.append(color)
        }
        saveColors()
        #if DEBUG
        print("已重置为 \(colors.count) 个预设颜色")
        #endif
    }
    
    // 添加特定品牌的所有颜色
    func addAllColorsForBrand(_ brand: String) {
        let brandColors = FilamentColor.colorsForBrand(brand)
        addColors(brandColors)
    }
    
    // 保存颜色库
    func saveColors() {
        do {
            let encoded = try JSONEncoder().encode(colors)
            UserDefaults.standard.set(encoded, forKey: saveKey)
            #if DEBUG
            print("保存了 \(colors.count) 个颜色到 UserDefaults")
            for (index, color) in colors.enumerated() {
                print("  \(index + 1). \(color.name): RGB(\(color.debugRed), \(color.debugGreen), \(color.debugBlue))")
            }
            #endif
        } catch {
            #if DEBUG
            print("颜色数据保存失败: \(error.localizedDescription)")
            #endif
        }
    }
    
    // 加载颜色库
    private func loadColors() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([FilamentColor].self, from: data)
                colors = decoded
                #if DEBUG
                print("从 UserDefaults 加载了 \(colors.count) 个颜色")
                for (index, color) in colors.enumerated() {
                    print("  \(index + 1). \(color.name): RGB(\(color.debugRed), \(color.debugGreen), \(color.debugBlue))")
                }
                #endif
                
                // 检查颜色数据是否有效
                var hasInvalidColors = false
                for color in colors where color.colorData.red == 0 && color.colorData.green == 0 && color.colorData.blue == 0 && color.colorData.alpha == 0 {
                    hasInvalidColors = true
                    break
                }
                
                // 如果有无效颜色数据，则重新加载预设颜色
                if hasInvalidColors {
                    #if DEBUG
                    print("检测到无效颜色数据，重置为预设颜色")
                    #endif
                    resetToDefaults()
                }
            } catch {
                #if DEBUG
                print("颜色数据加载失败: \(error.localizedDescription)")
                print("重置为预设颜色")
                #endif
                resetToDefaults()
            }
        } else {
            #if DEBUG
            print("未找到保存的颜色数据，使用预设颜色")
            #endif
            resetToDefaults()
        }
    }
    
    // 清除保存的数据并重置为预设颜色
    func clearSavedColorsAndReset() {
        #if DEBUG
        print("清除保存的颜色数据并重置")
        #endif
        UserDefaults.standard.removeObject(forKey: saveKey)
        resetToDefaults()
    }
    
    func addAllTinzhuPLABasicColors() {
        for color in FilamentColor.tinzhuPLABasicColors {
            // 检查颜色是否已存在
            let exists = colors.contains { $0.name == color.name && $0.brand == color.brand && $0.materialType == color.materialType }
            if !exists {
                addColor(color)
            }
        }
    }
} 