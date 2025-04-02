//
//  FillyApp.swift
//  Filly
//
//  Created by Jiawei Ren on 2025/3/25.
//

import SwiftUI
import SwiftData

@main
struct FillyApp: App {
    // 创建一个全局的ThemeManager实例
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var filamentLibraryViewModel = FilamentLibraryViewModel()
    @StateObject private var filamentViewModel = FilamentViewModel()
    
    // 使用 State 存储当前颜色方案
    @State private var activeColorScheme: ColorScheme? = nil
    
    // 模型容器配置
    @State private var container: ModelContainer? = nil
    
    init() {
        // 设置初始颜色方案
        let theme = ThemeManager().selectedTheme
        let _activeColorScheme = theme.colorScheme
        self._activeColorScheme = State(initialValue: _activeColorScheme)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if let modelContainer = container {
                    ContentView()
                        .environmentObject(themeManager)
                        .environmentObject(filamentViewModel)
                        .environmentObject(filamentLibraryViewModel)
                        .modelContainer(modelContainer)
                        // 应用主题
                        .preferredColorSchemeIfAvailable(activeColorScheme)
                        // 监听主题变更通知
                        .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { notification in
                            if let theme = notification.object as? ThemeMode {
                                activeColorScheme = theme.colorScheme
                            }
                        }
                        // 响应预备主题变更通知
                        .onReceive(NotificationCenter.default.publisher(for: .prepareForThemeChange)) { _ in
                            // 收到通知后，此视图不做任何特殊处理
                        }
                } else {
                    // 加载容器时显示加载中
                    SplashScreen(message: "正在准备数据...")
                        .onAppear {
                            setupModelContainer()
                        }
                }
            }
        }
    }
    
    // 初始化数据模型容器
    private func setupModelContainer() {
        do {
            let schema = Schema([
                SwiftDataBrand.self,
                SwiftDataMaterialType.self,
                SwiftDataFilamentColor.self
            ])
            
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("设置SwiftData容器时出错: \(error)")
        }
    }
}
