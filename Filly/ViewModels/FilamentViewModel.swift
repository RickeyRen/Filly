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
            Filament(brand: "Bambu Lab", type: .pla, color: "黑色", weight: 1000),
            Filament(brand: "天瑞 Tianrui", type: .petg, color: "蓝色", weight: 1000),
            Filament(brand: "易生 eSUN", type: .tpu, color: "透明", weight: 500)
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
    
    // 更新剩余量
    func updateRemainingPercentage(id: UUID, percentage: Double) {
        if let index = filaments.firstIndex(where: { $0.id == id }) {
            filaments[index].remainingPercentage = max(0, min(100, percentage))
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
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Filament].self, from: data) {
            filaments = decoded
        }
    }
    
    // 获取不同品牌的统计数据
    func brandStatistics() -> [(brand: String, count: Int)] {
        var brandCounts: [String: Int] = [:]
        
        for filament in filaments {
            brandCounts[filament.brand, default: 0] += 1
        }
        
        return brandCounts.map { (brand: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 获取不同类型的统计数据
    func typeStatistics() -> [(type: String, count: Int)] {
        var typeCounts: [String: Int] = [:]
        
        for filament in filaments {
            typeCounts[filament.type.rawValue, default: 0] += 1
        }
        
        return typeCounts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
} 