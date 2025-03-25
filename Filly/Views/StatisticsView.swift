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
                        Text("耗材总数")
                        Spacer()
                        Text("\(viewModel.filaments.count)")
                            .fontWeight(.bold)
                    }
                    
                    let totalWeight = viewModel.filaments.reduce(0) { $0 + $1.weight * ($1.remainingPercentage / 100) }
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
            Text("\(count)")
                .fontWeight(.bold)
        }
    }
} 