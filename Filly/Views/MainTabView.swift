import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var filamentViewModel: FilamentViewModel
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    
    var body: some View {
        TabView {
            FilamentListView(viewModel: filamentViewModel)
                .tabItem {
                    Label("我的耗材", systemImage: "list.bullet")
                }
            
            FilamentLibraryView()
                .tabItem {
                    Label("耗材库", systemImage: "square.grid.2x2")
                }
            
            StatisticsView(viewModel: filamentViewModel)
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