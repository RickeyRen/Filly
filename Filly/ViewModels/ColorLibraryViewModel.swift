import SwiftUI
import Combine

class ColorLibraryViewModel: ObservableObject {
    @Published var colors: [FilamentColor] = []
    @Published var selectedBrand: String = ""
    @Published var selectedMaterialType: String = ""
    
    private let saveKey = "savedColors"
    
    init() {
        loadColors()
        
        // 如果没有颜色，添加预设颜色
        if colors.isEmpty {
            colors = FilamentColor.presets
            saveColors()
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
        for color in colors {
            if !color.materialType.isEmpty {
                types.insert(color.materialType)
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
    
    // 添加拓竹所有颜色
    func addAllTinzhuPLABasicColors() {
        // 添加拓竹PLA Basic的所有颜色
        let tinzhuColors = [
            FilamentColor(name: "银色10102【含料盘】", color: Color(hex: "#C0C0C0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "红色10200【含料盘】", color: Color(hex: "#FF0000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "黑色10101【含料盘】", color: Color(hex: "#000000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "深蓝色10601【含料盘】", color: Color(hex: "#00008B"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "拓竹绿10501【含料盘】", color: Color(hex: "#2E8B57"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "金色10401【含料盘】", color: Color(hex: "#FFD700"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "青铜色10801【含料盘】", color: Color(hex: "#CD7F32"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "紫色10700【含料盘】", color: Color(hex: "#800080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "橙色10300【含料盘】", color: Color(hex: "#FFA500"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "灰蓝10602【含料盘】", color: Color(hex: "#6699CC"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "灰色10103【含料盘】", color: Color(hex: "#808080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "棕色10800【含料盘】", color: Color(hex: "#8B4513"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "浅杏色10201【含料盘】", color: Color(hex: "#FFCC99"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "粉红色10203【含料盘】", color: Color(hex: "#FFC0CB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "玉石白10100【含料盘】", color: Color(hex: "#F5F5F5"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "黄色10400【含料盘】", color: Color(hex: "#FFFF00"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "品红色10202【含料盘】", color: Color(hex: "#FF00FF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "青色10603【含料盘】", color: Color(hex: "#00FFFF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "圣诞绿10502【含料盘】", color: Color(hex: "#006400"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "南瓜橙10301【含料盘】", color: Color(hex: "#FF7518"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "暖黄色10402【含料盘】", color: Color(hex: "#FFD580"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "绀紫色10701【含料盘】", color: Color(hex: "#4B0082"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "桃红色10204【含料盘】", color: Color(hex: "#FF69B4"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "可可棕10802【含料盘】", color: Color(hex: "#D2691E"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            
            FilamentColor(name: "浅灰10104【无料盘】", color: Color(hex: "#D3D3D3"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "深灰10105【无料盘】", color: Color(hex: "#696969"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "金色10401【无料盘】", color: Color(hex: "#FFD700"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "紫色10700【无料盘】", color: Color(hex: "#800080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "品红色10202【无料盘】", color: Color(hex: "#FF00FF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "青色10603【无料盘】", color: Color(hex: "#00FFFF"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "圣诞绿10502【无料盘】", color: Color(hex: "#006400"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "青铜色10801【无料盘】", color: Color(hex: "#CD7F32"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "可可棕10802【无料盘】", color: Color(hex: "#D2691E"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "红色10200【无料盘】", color: Color(hex: "#FF0000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "南瓜橙10301【无料盘】", color: Color(hex: "#FF7518"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "暖黄色10402【无料盘】", color: Color(hex: "#FFD580"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "桃红色10204【无料盘】", color: Color(hex: "#FF69B4"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "钴蓝色10604【无料盘】", color: Color(hex: "#0047AB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "胭脂红10205【无料盘】", color: Color(hex: "#E34234"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "玉石白10100【无料盘】", color: Color(hex: "#F5F5F5"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "绀紫色10701【无料盘】", color: Color(hex: "#4B0082"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "橙色10300【无料盘】", color: Color(hex: "#FFA500"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "深蓝色10601【无料盘】", color: Color(hex: "#00008B"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "灰色10103【无料盘】", color: Color(hex: "#808080"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "浅杏色10201【无料盘】", color: Color(hex: "#FFCC99"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "银色10102【无料盘】", color: Color(hex: "#C0C0C0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "黄色10400【无料盘】", color: Color(hex: "#FFFF00"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "灰蓝10602【无料盘】", color: Color(hex: "#6699CC"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "粉红色10203【无料盘】", color: Color(hex: "#FFC0CB"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "棕色10800【无料盘】", color: Color(hex: "#8B4513"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "苹果绿10503【无料盘】", color: Color(hex: "#8DB600"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "松石绿10605【无料盘】", color: Color(hex: "#40E0D0"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "拓竹绿10501【无料盘】", color: Color(hex: "#2E8B57"), brand: "拓竹 Tinzhu", materialType: "PLA Basic"),
            FilamentColor(name: "黑色10101【无料盘】", color: Color(hex: "#000000"), brand: "拓竹 Tinzhu", materialType: "PLA Basic")
        ]
        
        for color in tinzhuColors {
            if !self.colors.contains(where: { $0.name == color.name }) {
                self.colors.append(color)
            }
        }
        
        saveColors()
        objectWillChange.send()
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