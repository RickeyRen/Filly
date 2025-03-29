import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("外观")) {
                    // 主题设置
                    Picker("主题", selection: $themeManager.selectedTheme) {
                        ForEach(ThemeMode.allCases) { theme in
                            HStack {
                                Image(systemName: theme.iconName)
                                    .foregroundColor(themeIconColor(for: theme))
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                }
                
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("关于应用")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "app.badge.checkmark")
                            .foregroundColor(.green)
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("设置")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private func themeIconColor(for theme: ThemeMode) -> Color {
        switch theme {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .purple
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Filly")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("3D打印耗材管理")
                    .font(.title3)
                
                Text("版本 1.0.0")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("© 2023 Jiawei Ren")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        // 关闭视图
                    }
                }
            }
        }
    }
} 