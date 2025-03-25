import Foundation
import SwiftUI

// 单盘耗材模型
struct FilamentSpool: Identifiable, Codable {
    var id = UUID()
    var remainingPercentage: Double // 剩余百分比（0-100）
    var dateAdded: Date
    var notes: String
    
    init(remainingPercentage: Double = 100, notes: String = "") {
        self.remainingPercentage = remainingPercentage
        self.dateAdded = Date()
        self.notes = notes
    }
} 