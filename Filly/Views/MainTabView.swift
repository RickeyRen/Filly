import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = FilamentViewModel()
    @StateObject private var colorLibrary = ColorLibraryViewModel()
    
    var body: some View {
        TabView {
            FilamentListView(viewModel: viewModel, colorLibrary: colorLibrary)
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