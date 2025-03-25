import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = FilamentViewModel()
    
    var body: some View {
        TabView {
            FilamentListView(viewModel: viewModel)
                .tabItem {
                    Label("库存", systemImage: "cube.box")
                }
            
            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("统计", systemImage: "chart.pie")
                }
        }
    }
} 