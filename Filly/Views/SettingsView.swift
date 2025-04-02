import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // 状态变量用于本地主题选择和计数器同步
    @State private var localTheme: ThemeMode = .system
    @State private var themeCounter: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("外观")) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("主题设置")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        ForEach(ThemeMode.allCases) { theme in
                            Button {
                                // 使用新的API安全地切换主题
                                NotificationCenter.default.post(name: .prepareForThemeChange, object: nil)
                                
                                // 延迟执行以确保通知被处理
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    themeManager.changeTheme(to: theme)
                                }
                                
                                // 更新本地状态
                                localTheme = theme
                            } label: {
                                HStack {
                                    Image(systemName: theme.iconName)
                                        .font(.system(size: 22))
                                        .foregroundColor(getThemeColor(for: theme))
                                        .frame(width: 30, height: 30)
                                    
                                    Text(theme.rawValue)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if themeManager.selectedTheme == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
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
            .onAppear {
                localTheme = themeManager.selectedTheme
                themeCounter = themeManager.themeChangeCounter
            }
            // 监听主题变更计数器更新
            .onChange(of: themeManager.themeChangeCounter) { _, newValue in
                themeCounter = newValue
            }
        }
    }
    
    // 主题颜色映射
    private func getThemeColor(for theme: ThemeMode) -> Color {
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