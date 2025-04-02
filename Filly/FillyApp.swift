//
//  FillyApp.swift
//  Filly
//
//  Created by Jiawei Ren on 2025/3/25.
//

import SwiftUI
import SwiftData
import CoreData

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
    @State private var isLoading = true
    
    init() {
        // 设置初始颜色方案
        let theme = ThemeManager().selectedTheme
        let _activeColorScheme = theme.colorScheme
        self._activeColorScheme = State(initialValue: _activeColorScheme)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    // 加载容器时显示加载中
                    SplashScreen(message: "正在准备数据...") {
                        // 加载完成后的回调
                        self.isLoading = false
                    }
                    .onAppear {
                        // 确保在出现时设置模型容器
                        setupModelContainer()
                    }
                } else if let modelContainer = container {
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
                    // 显示错误界面
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("数据加载失败")
                            .font(.title)
                        Button("重试") {
                            setupModelContainer()
                        }
                        .padding()
                        .buttonStyle(.bordered)
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
            
            // 创建更宽容的配置，设置迁移选项
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            // 处理可能的迁移错误
            do {
                container = try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("尝试正常加载失败，错误: \(error)")
                print("尝试删除现有数据库并重新创建...")
                
                // 删除现有数据库并创建新的
                let url = URL.applicationSupportDirectory.appending(component: "default.store")
                try? FileManager.default.removeItem(at: url)
                print("已删除旧数据库: \(url.path)")
                
                // 重新创建数据库
                container = try ModelContainer(for: schema, configurations: [config])
                print("成功创建新的数据库")
            }
            
            // 数据容器初始化成功后不要立即切换到内容视图
            // 让SplashScreen完成它的动画
        } catch {
            print("设置SwiftData容器时出错: \(error)")
            // 出错时也保持加载状态为true，显示错误视图
            container = nil
        }
    }
}
