import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: FilamentViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("品牌统计")) {
                    if viewModel.brandStatistics().isEmpty {
                        Text("暂无统计数据")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.brandStatistics(), id: \.brand) { stat in
                            StatRow(name: stat.brand, count: stat.count)
                        }
                    }
                }
                
                Section(header: Text("类型统计")) {
                    if viewModel.typeStatistics().isEmpty {
                        Text("暂无统计数据")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.typeStatistics(), id: \.type) { stat in
                            StatRow(name: stat.type, count: stat.count)
                        }
                    }
                }
                
                Section(header: Text("总览")) {
                    HStack {
                        Text("耗材类型总数")
                        Spacer()
                        Text("\(viewModel.filaments.count)")
                            .fontWeight(.bold)
                    }
                    
                    let totalSpools = viewModel.filaments.reduce(0) { $0 + $1.spools.count }
                    HStack {
                        Text("耗材盘总数")
                        Spacer()
                        Text("\(totalSpools)")
                            .fontWeight(.bold)
                    }
                    
                    let fullSpools = viewModel.filaments.reduce(0) { $0 + $1.fullSpoolCount }
                    HStack {
                        Text("全新耗材盘数")
                        Spacer()
                        Text("\(fullSpools)")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    let usedSpools = viewModel.filaments.reduce(0) { $0 + ($1.remainingSpoolCount - $1.fullSpoolCount) }
                    HStack {
                        Text("部分使用的耗材盘数")
                        Spacer()
                        Text("\(usedSpools)")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    let totalWeight = viewModel.filaments.reduce(0) { acc, filament in
                        acc + filament.spools.reduce(0) { $0 + filament.weight * ($1.remainingPercentage / 100) / Double(filament.spools.count) }
                    }
                    HStack {
                        Text("剩余总重量")
                        Spacer()
                        Text("\(Int(totalWeight))g")
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("耗材统计")
        }
    }
}

struct StatRow: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(count)盘")
                .fontWeight(.bold)
        }
    }
} 