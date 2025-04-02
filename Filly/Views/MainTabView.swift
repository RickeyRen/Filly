import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    @EnvironmentObject var filamentViewModel: FilamentViewModel
    @EnvironmentObject var colorLibrary: ColorLibraryViewModel
    
    var body: some View {
        TabView {
            FilamentListView(viewModel: filamentViewModel, colorLibrary: colorLibrary)
                .tabItem {
                    Label("我的耗材", systemImage: "square.stack.3d.up")
                }
            
            FilamentLibraryView()
                .environmentObject(filamentLibraryViewModel)
                .environmentObject(filamentViewModel)
                .environmentObject(colorLibrary)
                .tabItem {
                    Label("耗材库", systemImage: "books.vertical")
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