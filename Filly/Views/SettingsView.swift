import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var typeViewModel: FilamentTypeViewModel
    @State private var showingMaterialTypeManager = false
    @State private var localTheme: ThemeMode = .system
    
    // 监听主题变更计数器
    @State private var themeCounter: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("应用设置")) {
                    // 主题选择器 - 使用枚举作为选择项
                    VStack(alignment: .leading) {
                        Text("主题选择")
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