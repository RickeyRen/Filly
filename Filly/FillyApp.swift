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
    @StateObject private var filamentTypeViewModel = FilamentTypeViewModel()
    @StateObject private var filamentLibraryViewModel = FilamentLibraryViewModel()
    @StateObject private var filamentViewModel: FilamentViewModel
    
    // 使用 State 存储当前颜色方案
    @State private var activeColorScheme: ColorScheme? = nil
    
    // 模型容器配置
    @State private var container: ModelContainer? = nil
    
    // 使用 init() 确保 filamentViewModel 使用 filamentTypeViewModel
    init() {
        let typeVM = FilamentTypeViewModel()
        _filamentTypeViewModel = StateObject(wrappedValue: typeVM)
        _filamentViewModel = StateObject(wrappedValue: FilamentViewModel(typeViewModel: typeVM))
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if let container = container {
                    SplashScreen()
                        .environmentObject(themeManager)
                        .environmentObject(filamentTypeViewModel)
                        .environmentObject(filamentLibraryViewModel)
                        .environmentObject(filamentViewModel)
                        .modelContainer(container)
                        .preferredColorScheme(activeColorScheme)
                        // 监听主题准备变更通知
                        .onReceive(NotificationCenter.default.publisher(for: .prepareForThemeChange)) { _ in
                            // 主题即将变更，清理所有视图状态
                            clearAllViewState()
                        }
                        // 监听主题已变更通知
                        .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { notification in
                            if let theme = notification.object as? ThemeMode {
                                // 安全地更新颜色方案
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    activeColorScheme = theme.colorScheme
                                }
                            }
                        }
                } else {
                    // 显示加载指示器
                    ProgressView("初始化数据库...")
                        .onAppear(perform: setupModelContainer)
                }
            }
            .onAppear {
                // 初始化颜色方案
                activeColorScheme = themeManager.selectedTheme.colorScheme
            }
        }
    }
    
    // 设置模型容器
    private func setupModelContainer() {
        // 移至异步线程创建容器
        Task {
            do {
                let schema = Schema([
                    SwiftDataBrand.self,
                    SwiftDataMaterialType.self,
                    SwiftDataFilamentColor.self
                ])
                let config = ModelConfiguration("FillyLibraryDB", schema: schema)
                let newContainer = try ModelContainer(for: schema, configurations: config)
                
                // 回到主线程更新状态
                await MainActor.run {
                    self.container = newContainer
                }
            } catch {
                print("无法创建 SwiftData 容器: \(error.localizedDescription)")
            }
        }
    }
    
    // 清理所有视图状态
    private func clearAllViewState() {
        // 暂时不做具体实现，各视图通过自己的通知监听来处理
        print("准备切换主题，清理所有视图状态")
    }
}
