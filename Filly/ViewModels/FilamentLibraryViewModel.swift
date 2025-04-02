import Foundation
import SwiftUI
import SwiftData

/// 耗材库视图模型，管理耗材库数据
@MainActor
class FilamentLibraryViewModel: ObservableObject {
    
    // 当前选中的品牌和材料类型
    @Published var selectedBrand: SwiftDataBrand? = nil
    @Published var selectedMaterialType: SwiftDataMaterialType? = nil
    @Published var searchQuery: String = ""
    
    // MARK: - Initialization
    
    func initializePresetDataIfNeeded(context: ModelContext) {
        // Check if data already exists to avoid duplicates
        let descriptor = FetchDescriptor<SwiftDataBrand>()
        let count = try? context.fetchCount(descriptor)
        
        guard count == 0 else {
            print("耗材库预设数据已存在，跳过初始化。")
            return
        }
        
        print("正在初始化耗材库预设数据...")
        
        // 从预设数据文件加载所有品牌和颜色
        initializeFromPresetData(context: context)
        
        print("耗材库预设数据初始化完成。")
    }
    
    // 从预设数据文件加载所有品牌和颜色
    private func initializeFromPresetData(context: ModelContext) {
        // 遍历所有预设品牌
        for brandData in PresetFilamentData.brands {
            // 创建品牌
            let brand = SwiftDataBrand(name: brandData.name)
            context.insert(brand)
            
            // 为每个品牌添加材料类型
            for materialTypeData in brandData.materialTypes {
                let materialType = SwiftDataMaterialType(name: materialTypeData.name, brand: brand)
                context.insert(materialType)
                brand.materialTypes.append(materialType)
                
                // 为每个材料类型添加颜色
                for colorData in materialTypeData.colors {
                    // 处理含料盘和不含料盘版本
                    addColorFromPreset(
                        colorData: colorData,
                        materialType: materialType,
                        context: context
                    )
                    
                    // 如果每个颜色只定义了一次，这里需要添加其对应的料盘版本
                    if !isWholeSpoolDefinedSeparately(in: materialTypeData.colors) {
                        // 添加对应的不含料盘版本
                        if colorData.hasSpool {
                            var noSpoolColor = colorData
                            noSpoolColor = PresetFilamentData.ColorProperties(
                                name: colorData.name,
                                code: colorData.code,
                                hasSpool: false,
                                isTransparent: colorData.isTransparent,
                                isMetallic: colorData.isMetallic
                            )
                            addColorFromPreset(
                                colorData: noSpoolColor, 
                                materialType: materialType, 
                                context: context
                            )
                        }
                    }
                }
            }
        }
        
        // 保存上下文
        saveContext(context)
    }
    
    // 检查是否已经分别定义了含料盘和不含料盘版本
    private func isWholeSpoolDefinedSeparately(in colors: [PresetFilamentData.ColorProperties]) -> Bool {
        // 如果同一名称的颜色同时有料盘和无料盘两个版本，则认为是分别定义的
        let colorNames = Set(colors.map { $0.name })
        for name in colorNames {
            let sameNameColors = colors.filter { $0.name == name }
            if sameNameColors.count > 1 {
                let hasSpoolVersion = sameNameColors.contains { $0.hasSpool }
                let hasNoSpoolVersion = sameNameColors.contains { !$0.hasSpool }
                if hasSpoolVersion && hasNoSpoolVersion {
                    return true
                }
            }
        }
        return false
    }
    
    // 从预设数据添加颜色
    private func addColorFromPreset(colorData: PresetFilamentData.ColorProperties, materialType: SwiftDataMaterialType, context: ModelContext) {
        // 根据颜色名称获取合适的颜色
        let swiftUIColor = intelligentColorMapping(for: colorData.name)
        
        // 创建颜色数据
        let colorDataObj = SwiftDataColorData(from: swiftUIColor)
        
        // 设置颜色名称，包含料盘信息
        let suffix = colorData.hasSpool ? " (含料盘)" : " (无料盘)"
        let fullName = colorData.name + suffix
        
        // 创建颜色对象
        let filamentColor = SwiftDataFilamentColor(
            name: fullName,
            code: colorData.code,
            colorData: colorDataObj,
            isTransparent: colorData.isTransparent,
            isMetallic: colorData.isMetallic,
            hasSpool: colorData.hasSpool,
            materialType: materialType
        )
        
        // 添加到数据库
        context.insert(filamentColor)
        materialType.colors.append(filamentColor)
    }
    
    // MARK: - Data Fetching
    
    func fetchBrands(context: ModelContext) -> [SwiftDataBrand] {
        let descriptor = FetchDescriptor<SwiftDataBrand>(sortBy: [SortDescriptor(\.name)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("获取品牌失败: \(error)")
            return []
        }
    }
    
    func fetchMaterialTypes(for brand: SwiftDataBrand?, context: ModelContext) -> [SwiftDataMaterialType] {
        guard let brand = brand else { return [] }
        // Capture the non-optional ID outside the predicate
        let brandID = brand.id 
        let predicate = #Predicate<SwiftDataMaterialType> { 
            // Compare the optional chained ID with the captured non-optional ID
            $0.brand?.id == brandID 
        }
        let descriptor = FetchDescriptor<SwiftDataMaterialType>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("获取材料类型失败: \(error)")
            return []
        }
    }
    
    func fetchColors(for materialType: SwiftDataMaterialType?, context: ModelContext) -> [SwiftDataFilamentColor] {
        guard let materialType = materialType else { return [] }
        // Capture the non-optional ID outside the predicate
        let materialTypeID = materialType.id
        let predicate = #Predicate<SwiftDataFilamentColor> { 
            // Compare the optional chained ID with the captured non-optional ID
            $0.materialType?.id == materialTypeID 
        }
        let descriptor = FetchDescriptor<SwiftDataFilamentColor>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("获取颜色失败: \(error)")
            return []
        }
    }
    
    // MARK: - Search
    
    func searchLibrary(query: String, context: ModelContext) -> [SwiftDataFilamentColor] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty { return [] } // Return empty if search is empty
        
        // Predicate to search across color name, material type, and brand name
        let predicate = #Predicate<SwiftDataFilamentColor> { color in
            color.name.localizedStandardContains(trimmedQuery) ||
            (color.materialType?.name.localizedStandardContains(trimmedQuery) ?? false) ||
            (color.materialType?.brand?.name.localizedStandardContains(trimmedQuery) ?? false)
        }
        
        let descriptor = FetchDescriptor<SwiftDataFilamentColor>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.materialType?.brand?.name), SortDescriptor(\.materialType?.name), SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("搜索耗材库失败: \(error)")
            return []
        }
    }
    
    // MARK: - Data Management (Optional - Add/Delete if needed for library management later)
    
    func addBrand(name: String, context: ModelContext) {
        let brand = SwiftDataBrand(name: name)
        context.insert(brand)
        saveContext(context)
    }
    
    func deleteBrand(_ brand: SwiftDataBrand, context: ModelContext) {
        context.delete(brand)
        saveContext(context)
    }
    
    // Similar functions for MaterialType and FilamentColor can be added here...
    
    // 添加材料类型到品牌
    func addMaterialType(name: String, to brand: SwiftDataBrand, context: ModelContext) {
        let materialType = SwiftDataMaterialType(name: name, brand: brand)
        context.insert(materialType)
        brand.materialTypes.append(materialType)
        saveContext(context)
    }
    
    // 删除材料类型
    func deleteMaterialType(_ materialType: SwiftDataMaterialType, context: ModelContext) {
        context.delete(materialType)
        saveContext(context)
    }
    
    // 添加颜色到材料类型
    func addColor(name: String, colorData: SwiftDataColorData, to materialType: SwiftDataMaterialType, context: ModelContext, 
                 code: String? = nil, isTransparent: Bool = false, isMetallic: Bool = false, hasSpool: Bool = true) {
        let color = SwiftDataFilamentColor(
            name: name,
            code: code,
            colorData: colorData,
            isTransparent: isTransparent,
            isMetallic: isMetallic,
            hasSpool: hasSpool,
            materialType: materialType
        )
        context.insert(color)
        materialType.colors.append(color)
        saveContext(context)
    }
    
    // 根据颜色名称智能映射到颜色
    private func intelligentColorMapping(for name: String) -> Color {
        let lowercaseName = name.lowercased()
        
        // 基本颜色
        if lowercaseName.contains("黑色") { return .black }
        if lowercaseName.contains("冷白") || lowercaseName.contains("白") { return .white }
        if lowercaseName.contains("红色") || lowercaseName.contains("玫红") { return .red }
        if lowercaseName.contains("蓝色") || lowercaseName.contains("天空蓝") { return Color(red: 0.0, green: 0.5, blue: 1.0) }
        if lowercaseName.contains("绿色") { return .green }
        if lowercaseName.contains("黄色") || lowercaseName.contains("亮丽黄") { return .yellow }
        if lowercaseName.contains("橙色") { return .orange }
        if lowercaseName.contains("紫色") || lowercaseName.contains("紫红") { return .purple }
        if lowercaseName.contains("粉色") || lowercaseName.contains("樱花粉") { return .pink }
        if lowercaseName.contains("灰色") || lowercaseName.contains("太空灰") { return .gray }
        
        // 特殊颜色
        if lowercaseName.contains("透明") { 
            if lowercaseName.contains("蓝") { return Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.7) }
            if lowercaseName.contains("绿") { return Color(red: 0.7, green: 1.0, blue: 0.8, opacity: 0.7) }
            if lowercaseName.contains("红") { return Color(red: 1.0, green: 0.7, blue: 0.7, opacity: 0.7) }
            return Color(white: 0.9, opacity: 0.5) 
        }
        
        if lowercaseName.contains("咖啡") { return Color(red: 0.6, green: 0.4, blue: 0.2) }
        if lowercaseName.contains("荧光绿") { return Color(red: 0.4, green: 1.0, blue: 0.4) }
        if lowercaseName.contains("荧光黄") { return Color(red: 1.0, green: 1.0, blue: 0.4) }
        if lowercaseName.contains("杏色") { return Color(red: 1.0, green: 0.8, blue: 0.6) }
        if lowercaseName.contains("奶白") { return Color(white: 0.95) }
        if lowercaseName.contains("米宝白") { return Color(red: 0.98, green: 0.98, blue: 0.94) }
        if lowercaseName.contains("肤色") { return Color(red: 1.0, green: 0.87, blue: 0.73) }
        if lowercaseName.contains("淡灰") { return Color(white: 0.85) }
        if lowercaseName.contains("夜光绿") { return Color(red: 0.6, green: 1.0, blue: 0.6) }
        if lowercaseName.contains("薄荷绿") { return Color(red: 0.6, green: 1.0, blue: 0.8) }
        if lowercaseName.contains("卡特黄") { return Color(red: 1.0, green: 0.9, blue: 0.5) }
        if lowercaseName.contains("橄榄绿") { return Color(red: 0.5, green: 0.6, blue: 0.3) }
        if lowercaseName.contains("克莱因蓝") { return Color(red: 0.0, green: 0.3, blue: 0.7) }
        
        // 金属色
        if lowercaseName.contains("金属") {
            if lowercaseName.contains("紫") { return Color(red: 0.5, green: 0.3, blue: 0.7) }
            if lowercaseName.contains("香槟金") { return Color(red: 0.9, green: 0.8, blue: 0.6) }
            if lowercaseName.contains("午夜绿") { return Color(red: 0.2, green: 0.3, blue: 0.3) }
            if lowercaseName.contains("银") { return Color(white: 0.8) }
            if lowercaseName.contains("铜") { return Color(red: 0.7, green: 0.5, blue: 0.3) }
            if lowercaseName.contains("绿") { return Color(red: 0.3, green: 0.5, blue: 0.4) }
            if lowercaseName.contains("珠光蓝") { return Color(red: 0.4, green: 0.5, blue: 0.7) }
            if lowercaseName.contains("玫瑰金") { return Color(red: 0.9, green: 0.7, blue: 0.6) }
        }
        
        // 碳纤维
        if lowercaseName.contains("碳纤维") {
            if lowercaseName.contains("大理石灰") { return Color(white: 0.7) }
            if lowercaseName.contains("咖啡") { return Color(red: 0.4, green: 0.3, blue: 0.2) }
            return Color(white: 0.3) // 碳纤维黑色
        }
        
        // 高速系列
        if lowercaseName.contains("高速") {
            if lowercaseName.contains("薰衣草紫") { return Color(red: 0.8, green: 0.7, blue: 1.0) }
            if lowercaseName.contains("桃红") { return Color(red: 1.0, green: 0.5, blue: 0.7) }
            if lowercaseName.contains("浅蓝") { return Color(red: 0.7, green: 0.8, blue: 1.0) }
        }
        
        // 大理石系列
        if lowercaseName.contains("大理石") {
            if lowercaseName.contains("魔幻紫") { return Color(red: 0.6, green: 0.4, blue: 0.7) }
            if lowercaseName.contains("魔幻蓝") { return Color(red: 0.4, green: 0.5, blue: 0.7) }
            if lowercaseName.contains("魔幻绿") { return Color(red: 0.4, green: 0.7, blue: 0.5) }
            if lowercaseName.contains("魔幻棕") { return Color(red: 0.6, green: 0.4, blue: 0.3) }
            if lowercaseName.contains("浅灰") { return Color(white: 0.8) }
            if lowercaseName.contains("白") { return Color(white: 0.95) }
            return Color(white: 0.7) // 默认大理石色
        }
        
        // 默认颜色
        return .gray
    }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("保存数据库上下文失败: \(error)")
        }
    }
} 