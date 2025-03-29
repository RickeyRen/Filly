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
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        }
    }
}
