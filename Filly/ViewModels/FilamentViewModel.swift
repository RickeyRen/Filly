import Foundation
import SwiftUI

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
        let samples = [
            Filament(brand: "Bambu Lab", type: .pla, color: "黑色", weight: 1000, 
                     spools: [
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 80, notes: "轻微受潮")
                     ]),
            Filament(brand: "天瑞 Tianrui", type: .petg, color: "蓝色", weight: 1000,
                     spools: [
                        FilamentSpool(remainingPercentage: 100),
                        FilamentSpool(remainingPercentage: 20, notes: "打印床校准测试用")
                     ]),
            Filament(brand: "易生 eSUN", type: .tpu, color: "透明", weight: 500,
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
    func deleteFilament(at offsets: IndexSet) {
        filaments.remove(atOffsets: offsets)
        saveFilaments()
    }
    
    // 删除指定ID的耗材
    func deleteFilament(id: UUID) {
        if let index = filaments.firstIndex(where: { $0.id == id }) {
            filaments.remove(at: index)
            saveFilaments()
        }
    }
    
    // 标记耗材为用完
    func markAsEmpty(id: UUID) {
        if let index = filaments.firstIndex(where: { $0.id == id }) {
            filaments.remove(at: index)
            saveFilaments()
        }
    }
    
    // 更新耗材信息
    func updateFilament(_ filament: Filament) {
        if let index = filaments.firstIndex(where: { $0.id == filament.id }) {
            filaments[index] = filament
            saveFilaments()
        }
    }
    
    // 更新耗材盘的剩余量
    func updateSpoolPercentage(filamentId: UUID, spoolId: UUID, percentage: Double) {
        if let filamentIndex = filaments.firstIndex(where: { $0.id == filamentId }),
           let spoolIndex = filaments[filamentIndex].spools.firstIndex(where: { $0.id == spoolId }) {
            filaments[filamentIndex].spools[spoolIndex].remainingPercentage = max(0, min(100, percentage))
            saveFilaments()
        }
    }
    
    // 移除空盘
    func removeEmptySpool(filamentId: UUID, spoolId: UUID) {
        print("开始删除耗材盘")
        
        // 直接修改数据源
        for i in 0..<filaments.count {
            if filaments[i].id == filamentId {
                print("找到对应耗材，共有\(filaments[i].spools.count)个耗材盘")
                
                // 直接通过索引操作
                let oldCount = filaments[i].spools.count
                filaments[i].spools.removeAll { $0.id == spoolId }
                
                print("删除后还剩\(filaments[i].spools.count)个耗材盘")
                
                // 检查是否全部删除
                if filaments[i].spools.isEmpty {
                    print("所有耗材盘已删除，移除整个耗材")
                    filaments.remove(at: i)
                }
                
                // 保存并刷新UI
                saveFilaments()
                objectWillChange.send()
                
                print("删除操作完成")
                return
            }
        }
        
        print("未找到要删除的耗材")
    }
    
    // 添加新的耗材盘
    func addSpool(to filamentId: UUID) {
        if let index = filaments.firstIndex(where: { $0.id == filamentId }) {
            var updatedFilament = filaments[index]
            let newSpool = FilamentSpool(remainingPercentage: 100)
            updatedFilament.spools.insert(newSpool, at: 0) // 将新耗材盘插入到数组的第一个位置
            filaments[index] = updatedFilament
            saveFilaments()
        }
    }
    
    // 保存数据
    private func saveFilaments() {
        print("保存数据中...")
        do {
            let encoded = try JSONEncoder().encode(filaments)
            UserDefaults.standard.set(encoded, forKey: saveKey)
            UserDefaults.standard.synchronize() // 立即保存
            print("数据保存成功")
        } catch {
            print("数据保存失败: \(error)")
        }
    }
    
    // 加载数据
    private func loadFilaments() {
        print("ViewModel: 开始加载耗材数据")
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([Filament].self, from: data)
                filaments = decoded
                print("ViewModel: 耗材数据加载成功，共\(filaments.count)个耗材")
            } catch {
                print("ViewModel: 解析耗材数据失败: \(error.localizedDescription)")
                filaments = []
            }
        } else {
            print("ViewModel: 未找到保存的耗材数据")
            filaments = []
        }
    }
    
    // 获取不同品牌的统计数据
    func brandStatistics() -> [(brand: String, count: Int)] {
        var brandCounts: [String: Int] = [:]
        
        for filament in filaments {
            brandCounts[filament.brand, default: 0] += filament.spools.count
        }
        
        return brandCounts.map { (brand: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 获取不同类型的统计数据
    func typeStatistics() -> [(type: String, count: Int)] {
        var typeCounts: [String: Int] = [:]
        
        for filament in filaments {
            typeCounts[filament.type.rawValue, default: 0] += filament.spools.count
        }
        
        return typeCounts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
} 