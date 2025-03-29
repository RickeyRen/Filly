//
//  FillyApp.swift
//  Filly
//
//  Created by Jiawei Ren on 2025/3/25.
//

import SwiftUI

@main
struct FillyApp: App {
    // 创建一个全局的ThemeManager实例
    @StateObject private var themeManager = ThemeManager()
    @State private var themeChangeCounter = 0
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .id(themeChangeCounter) // 强制UI刷新
                .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { _ in
                    // 仅增加计数器来触发UI刷新
                    themeChangeCounter += 1
                }
        }
    }
}
