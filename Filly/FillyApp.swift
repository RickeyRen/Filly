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
    
    // 使用 State 存储当前颜色方案，而不是直接从 themeManager 读取
    @State private var activeColorScheme: ColorScheme? = nil
    
    // 使用 init() 确保 filamentViewModel 使用 filamentTypeViewModel
    init() {
        let typeVM = FilamentTypeViewModel()
        _filamentTypeViewModel = StateObject(wrappedValue: typeVM)
        _filamentViewModel = StateObject(wrappedValue: FilamentViewModel(typeViewModel: typeVM))
    }

    var body: some Scene {
        // Define the SwiftData model container configuration
        let container: ModelContainer = {
            let schema = Schema([
                SwiftDataBrand.self,
                SwiftDataMaterialType.self,
                SwiftDataFilamentColor.self
                // Do NOT include Legacy models here
            ])
            let config = ModelConfiguration("FillyLibraryDB", schema: schema)
            do {
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("无法创建 SwiftData 容器: \(error.localizedDescription)")
            }
        }()

        WindowGroup {
            SplashScreen()
                .environmentObject(themeManager)
                .environmentObject(filamentTypeViewModel) // Add the new type VM
                .environmentObject(filamentLibraryViewModel)
                .environmentObject(filamentViewModel)
                .modelContainer(container)
                // 使用本地状态变量设置颜色方案，而不是直接绑定到themeManager
                .preferredColorScheme(activeColorScheme)
                // 监听主题变更通知
                .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { notification in
                    if let theme = notification.object as? ThemeMode {
                        // 安全地更新颜色方案
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeColorScheme = theme.colorScheme
                        }
                    }
                }
                .onAppear {
                    // 初始化颜色方案
                    activeColorScheme = themeManager.selectedTheme.colorScheme
                }
        }
    }
}
