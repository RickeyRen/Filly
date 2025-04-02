import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var typeViewModel: FilamentTypeViewModel
    @State private var showingMaterialTypeManager = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("应用设置")) {
                    Picker("主题", selection: $themeManager.selectedTheme) {
                        ForEach(ThemeMode.allCases) { theme in
                            HStack {
                                Image(systemName: theme.iconName)
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                }
                
                Section(header: Text("耗材管理")) {
                    Button(action: {
                        showingMaterialTypeManager = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            Text("管理材料类型")
                        }
                    }
                }
                
                Section(header: Text("关于应用")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        Text("Filly 版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showingMaterialTypeManager) {
                MaterialTypeManagerView()
            }
        }
    }
} 