import Foundation
import SwiftUI
import SwiftData

class FilamentViewModel: ObservableObject {
    @Published var filaments: [Filament] = []
    private let saveKey = "savedFilaments"
    
    init() {
        loadFilaments()
        
        // 如果没有数据，添加一些示例数据
        if filaments.isEmpty {
            addSampleData()
        }
    }
    
    // 添加示例数据
    private func addSampleData() {
        // 创建材料类型
        let plaType = FilamentTypeModel(name: "PLA")
        let petgType = FilamentTypeModel(name: "PETG")
        let tpuType = FilamentTypeModel(name: "TPU")
        
        let samples = [
            Filament(brand: "拓竹 Bambu Lab", type: plaType, color: "黑色", weight: 1000, 
                     spools: [
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 80, notes: "轻微受潮")
                     ]),
            Filament(brand: "天瑞 Tinmorry", type: petgType, color: "蓝色", weight: 1000,
                     spools: [
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 20, notes: "打印床校准测试用")
                     ]),
            Filament(brand: "易生 eSUN", type: tpuType, color: "透明", weight: 500,
                     spools: [FilamentSpool(remainingPercentage: 100)])
        ]
        
        filaments.append(contentsOf: samples)
        saveFilaments()
    }
    
    // 添加新耗材
    func addFilament(_ filament: Filament) {
        filaments.append(filament)
        saveFilaments()
    }
    
    // 删除耗材
    func deleteFilament(id: UUID) {
        filaments.removeAll { $0.id == id }
        saveFilaments()
    }
    
    // 更新现有耗材
    func updateFilament(_ filament: Filament) {
        if let index = filaments.firstIndex(where: { $0.id == filament.id }) {
            filaments[index] = filament
            saveFilaments()
        }
    }
    
    // 更新耗材盘
    func updateSpool(filamentId: UUID, spoolIndex: Int, remainingPercentage: Double, notes: String = "") {
        if let index = filaments.firstIndex(where: { $0.id == filamentId }) {
            if spoolIndex < filaments[index].spools.count {
                filaments[index].spools[spoolIndex].remainingPercentage = remainingPercentage
                filaments[index].spools[spoolIndex].notes = notes
                saveFilaments()
            }
        }
    }
    
    // 添加耗材盘
    func addSpool(filamentId: UUID, remainingPercentage: Double = 100, notes: String = "") {
        if let index = filaments.firstIndex(where: { $0.id == filamentId }) {
            filaments[index].spools.append(FilamentSpool(remainingPercentage: remainingPercentage, notes: notes))
            saveFilaments()
        }
    }
    
    // 更新耗材盘百分比
    func updateSpoolPercentage(filamentId: UUID, spoolId: UUID, percentage: Double) {
        if let filamentIndex = filaments.firstIndex(where: { $0.id == filamentId }),
           let spoolIndex = filaments[filamentIndex].spools.firstIndex(where: { $0.id == spoolId }) {
            filaments[filamentIndex].spools[spoolIndex].remainingPercentage = max(0, min(100, percentage))
            saveFilaments()
        }
    }
    
    // 删除耗材盘
    func deleteSpool(filamentId: UUID, spoolIndex: Int) {
        if let index = filaments.firstIndex(where: { $0.id == filamentId }) {
            if spoolIndex < filaments[index].spools.count {
                filaments[index].spools.remove(at: spoolIndex)
                saveFilaments()
            }
        }
    }
    
    // 通过ID删除耗材盘
    func removeEmptySpool(filamentId: UUID, spoolId: UUID) {
        if let filamentIndex = filaments.firstIndex(where: { $0.id == filamentId }) {
            filaments[filamentIndex].spools.removeAll(where: { $0.id == spoolId })
            saveFilaments()
        }
    }
    
    // 保存数据
    private func saveFilaments() {
        if let encoded = try? JSONEncoder().encode(filaments) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 加载数据
    private func loadFilaments() {
        if let savedFilaments = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedFilaments = try? JSONDecoder().decode([Filament].self, from: savedFilaments) {
                self.filaments = decodedFilaments
                return
            }
        }
        self.filaments = []
    }
    
    // 查找或创建对应的材料类型
    func findOrCreateType(name: String) -> FilamentTypeModel {
        // 查找现有类型
        for filament in filaments {
            if filament.type.name.lowercased() == name.lowercased() {
                return filament.type
            }
        }
        // 创建新类型
        return FilamentTypeModel(name: name)
    }
    
    // MARK: - 统计信息
    
    // 品牌统计
    func brandStatistics() -> [(brand: String, count: Int)] {
        var brandCounts: [String: Int] = [:]
        
        for filament in filaments {
            brandCounts[filament.brand, default: 0] += filament.spools.count
        }
        
        return brandCounts.map { (brand: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 类型统计
    func typeStatistics() -> [(type: String, count: Int)] {
        var typeCounts: [String: Int] = [:]
        
        for filament in filaments {
            typeCounts[filament.type.name, default: 0] += filament.spools.count
        }
        
        return typeCounts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
} 