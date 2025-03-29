//
//  FillyApp.swift
//  Filly
//
//  Created by Jiawei Ren on 2025/3/25.
//

import SwiftUI

@main
struct FillyApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var themeChangeCounter = 0
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .id(themeChangeCounter) // 强制UI刷新
                .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { _ in
                    themeChangeCounter += 1
                }
        }
    }
}
