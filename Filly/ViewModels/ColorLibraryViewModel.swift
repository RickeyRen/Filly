import SwiftUI
import Combine

class ColorLibraryViewModel: ObservableObject {
    @Published var colors: [FilamentColor] = []
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
            return colors
        }
        
        return colors.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    // 保存颜色库
    private func saveColors() {
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