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
        initializePresetData(in: context)
        print("耗材库预设数据初始化完成。")
    }
    
    private func initializePresetData(in context: ModelContext) {
        // --- 拓竹 Bambu Lab ---
        let bambuLab = SwiftDataBrand(name: "拓竹 Bambu Lab")
        context.insert(bambuLab)
        
        // PLA Lite for Bambu Lab
        let plaLite = SwiftDataMaterialType(name: "PLA Lite", brand: bambuLab)
        context.insert(plaLite)
        bambuLab.materialTypes.append(plaLite)
        
        // Define color data including name, code, and spool status
        let bambuColors: [(name: String, code: String, hasSpool: Bool)] = [
            ("黑色",   "16100", true), ("黑色",   "16100", false),
            ("天蓝色", "16600", true), ("天蓝色", "16600", false),
            ("黄色",   "16400", true), ("黄色",   "16400", false),
            ("白色",   "16103", true), ("白色",   "16103", false),
            ("红色",   "16200", true), ("红色",   "16200", false),
            ("灰色",   "16101", true), ("灰色",   "16101", false)
        ]
        
        for (colorName, productCode, hasSpool) in bambuColors {
            let suffix = hasSpool ? " (含料盘)" : " (无料盘)" // Correct suffix is used
            let fullName = colorName + suffix
            let swiftUIColor = colorMapping(for: colorName)
            let colorData = SwiftDataColorData(from: swiftUIColor)
            
            let filamentColor = SwiftDataFilamentColor(
                name: fullName,
                code: productCode, // Pass the product code here
                colorData: colorData,
                hasSpool: hasSpool,
                materialType: plaLite
            )
            context.insert(filamentColor)
            plaLite.colors.append(filamentColor)
        }
        
        // --- 天瑞 Tinmorry --- (Only add the brand, no types or colors initially)
        let tianrui = SwiftDataBrand(name: "天瑞 Tinmorry")
        context.insert(tianrui)
        // We are not adding PETG-ECO or its colors here as requested.
        // You can add them later via a management interface or by modifying this code.
        
        // --- Remove other brands --- 
        // Any code previously here for other brands like Polymaker, eSUN etc. is removed.
        
        // Save the context after inserting all desired data
        do {
            try context.save()
        } catch {
            print("保存预设数据失败: \(error)")
        }
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
    
    // 为天瑞添加PETG-ECO系列颜色
    func addTianruiPETGECOColors(context: ModelContext) {
        // 查找天瑞品牌
        let descriptor = FetchDescriptor<SwiftDataBrand>(predicate: #Predicate { $0.name.contains("天瑞") })
        
        do {
            let brands = try context.fetch(descriptor)
            guard let tianrui = brands.first else {
                print("未找到天瑞品牌，创建新品牌")
                let tianrui = SwiftDataBrand(name: "天瑞 Tinmorry")
                context.insert(tianrui)
                addPETGECOToTianrui(tianrui, context: context)
                return
            }
            
            // 找到现有品牌，添加材料类型和颜色
            addPETGECOToTianrui(tianrui, context: context)
            
        } catch {
            print("查找天瑞品牌失败: \(error)")
        }
    }
    
    private func addPETGECOToTianrui(_ tianrui: SwiftDataBrand, context: ModelContext) {
        // 检查是否已存在PETG-ECO材料类型
        let materialDescriptor = FetchDescriptor<SwiftDataMaterialType>(
            predicate: #Predicate { $0.name == "PETG-ECO" && $0.brand?.id == tianrui.id }
        )
        
        let petgEco: SwiftDataMaterialType
        
        do {
            let types = try context.fetch(materialDescriptor)
            if let existingType = types.first {
                petgEco = existingType
                print("找到现有PETG-ECO材料类型")
            } else {
                // 创建新材料类型
                petgEco = SwiftDataMaterialType(name: "PETG-ECO", brand: tianrui)
                context.insert(petgEco)
                tianrui.materialTypes.append(petgEco)
                print("创建新PETG-ECO材料类型")
            }
            
            // 添加所有颜色
            addTianruiColorsToPETGECO(petgEco, context: context)
            
            try context.save()
            print("成功添加天瑞PETG-ECO系列颜色")
            
        } catch {
            print("添加PETG-ECO材料类型失败: \(error)")
        }
    }
    
    private func addTianruiColorsToPETGECO(_ petgEco: SwiftDataMaterialType, context: ModelContext) {
        // 定义所有颜色
        let colors: [(name: String, isTransparent: Bool, isMetallic: Bool)] = [
            ("亮丽黄", false, false),
            ("咖啡色", false, false),
            ("透明", true, false),
            ("荧光绿", false, false),
            ("荧光黄", false, false),
            ("红色", false, false),
            ("绿色", false, false),
            ("灰色", false, false),
            ("杏色", false, false),
            ("黑色", false, false),
            ("冷白", false, false),
            ("奶白色", false, false),
            ("米宝白", false, false),
            ("肤色", false, false),
            ("淡灰色", false, false),
            ("夜光绿", false, false),
            ("橙色", false, false),
            ("樱花粉", false, false),
            ("粉色", false, false),
            ("长春花蓝", false, false),
            ("薄荷绿", false, false),
            ("卡特黄", false, false),
            ("天空蓝", false, false),
            ("橄榄绿", false, false),
            ("透明蓝", true, false),
            ("透明绿", true, false),
            ("透明红", true, false),
            ("荧光玫红", false, false),
            ("荧光紫红", false, false),
            ("克莱因蓝", false, false),
            ("金属紫", false, true),
            ("金属香槟金", false, true),
            ("金属午夜绿", false, true),
            ("金属银", false, true),
            ("金属太空灰", false, true),
            ("金属铜", false, true),
            ("金属绿", false, true),
            ("金属珠光蓝", false, true),
            ("金属玫瑰金", false, true),
            ("petg碳纤维黑色", false, false),
            ("PETG碳纤维大理石灰", false, false),
            ("PETG碳纤维咖啡色", false, false),
            ("高速Petg薰衣草紫", false, false),
            ("高速Petg桃红", false, false),
            ("高速Petg黑色", false, false),
            ("高速Petg浅蓝", false, false),
            ("高速Petg冷白", false, false),
            ("Petg大理石花岗岩", false, false),
            ("大理石魔幻棕", false, false),
            ("大理石浅灰", false, false),
            ("大理石白", false, false),
            ("petg大理石魔幻紫", false, false),
            ("petg大理石魔幻蓝", false, false),
            ("Petg大理石魔幻绿", false, false)
        ]
        
        // 为每种颜色添加含料盘和不含料盘两种版本
        for (colorName, isTransparent, isMetallic) in colors {
            // 根据颜色名称获取合适的颜色
            let swiftUIColor = intelligentColorMapping(for: colorName)
            
            // 添加含料盘版本
            let colorWithSpool = "\(colorName) (含料盘)"
            let colorDataWithSpool = SwiftDataColorData(from: swiftUIColor)
            
            let filamentColorWithSpool = SwiftDataFilamentColor(
                name: colorWithSpool,
                colorData: colorDataWithSpool,
                isTransparent: isTransparent,
                isMetallic: isMetallic,
                hasSpool: true,
                materialType: petgEco
            )
            context.insert(filamentColorWithSpool)
            petgEco.colors.append(filamentColorWithSpool)
            
            // 添加不含料盘版本
            let colorWithoutSpool = "\(colorName) (无料盘)"
            let colorDataWithoutSpool = SwiftDataColorData(from: swiftUIColor)
            
            let filamentColorWithoutSpool = SwiftDataFilamentColor(
                name: colorWithoutSpool,
                colorData: colorDataWithoutSpool,
                isTransparent: isTransparent,
                isMetallic: isMetallic,
                hasSpool: false,
                materialType: petgEco
            )
            context.insert(filamentColorWithoutSpool)
            petgEco.colors.append(filamentColorWithoutSpool)
        }
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