import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = FilamentViewModel()
    @StateObject private var colorLibrary = ColorLibraryViewModel()
    @EnvironmentObject var themeManager: ThemeManager // 从环境中获取，而不是创建新实例
    
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
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
    }
} 