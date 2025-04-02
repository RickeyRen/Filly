import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    @EnvironmentObject var filamentViewModel: FilamentViewModel
    @EnvironmentObject var colorLibrary: ColorLibraryViewModel
    
    // State to control the selected tab
    @State private var selectedTab: Int = 0 // 0 for the first tab (My Filaments)
    
    var body: some View {
        // Use TabView with selection binding
        TabView(selection: $selectedTab) {
            // Tab 1: User Filaments (Existing)
            // Pass the selectedTab binding to FilamentListView
            FilamentListView(viewModel: filamentViewModel, colorLibrary: colorLibrary, selectedTab: $selectedTab)
                .tabItem {
                    Label("我的耗材", systemImage: "square.stack.3d.up")
                }
                .tag(0) // Assign tag 0 to this tab
            
            // Tab 2: Filament Library (New)
            FilamentLibraryView()
                .environmentObject(filamentLibraryViewModel)
                .environmentObject(filamentViewModel) 
                .environmentObject(colorLibrary)
                .tabItem {
                    Label("耗材库", systemImage: "books.vertical")
                }
                .tag(1) // Assign tag 1 to this tab
            
            // Tab 3: Statistics (Existing)
            StatisticsView(viewModel: filamentViewModel)
                .tabItem {
                    Label("统计", systemImage: "chart.pie")
                }
                .tag(2) // Assign tag 2 to this tab
            
            // Tab 4: Settings (Existing)
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(3) // Assign tag 3 to this tab
        }
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
    }
} 