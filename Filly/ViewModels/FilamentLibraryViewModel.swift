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
        
        let bambuColors: [(name: String, hasSpool: Bool)] = [
            ("黑色", true), ("黑色", false),
            ("天蓝色", true), ("天蓝色", false),
            ("黄色", true), ("黄色", false),
            ("白色", true), ("白色", false),
            ("红色", true), ("红色", false),
            ("灰色", true), ("灰色", false)
        ]
        
        for (colorName, hasSpool) in bambuColors {
            let suffix = hasSpool ? " (含料盘)" : " (无料盘)"
            let fullName = colorName + suffix
            let swiftUIColor = colorMapping(for: colorName)
            let colorData = SwiftDataColorData(from: swiftUIColor)
            
            let filamentColor = SwiftDataFilamentColor(
                name: fullName,
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
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("保存数据库上下文失败: \(error)")
        }
    }
} 