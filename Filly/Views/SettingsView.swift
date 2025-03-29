import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("外观")) {
                    // 显示当前选择的主题
                    HStack {
                        Label("当前主题", systemImage: themeManager.selectedTheme.iconName)
                            .foregroundColor(themeIconColor(for: themeManager.selectedTheme))
                        Spacer()
                        Text(themeManager.selectedTheme.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    // 主题选择按钮组
                    ForEach(ThemeMode.allCases) { theme in
                        Button(action: {
                            themeManager.selectedTheme = theme
                        }) {
                            HStack {
                                Image(systemName: theme.iconName)
                                    .foregroundColor(themeIconColor(for: theme))
                                    .font(.system(size: 18))
                                
                                Text(theme.rawValue)
                                
                                Spacer()
                                
                                if themeManager.selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
                AboutView(isPresented: $showingAbout)
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
    @Binding var isPresented: Bool
    
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
                        isPresented = false
                    }
                }
            }
        }
    }
} 