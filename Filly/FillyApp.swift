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
    @StateObject private var filamentViewModel = FilamentViewModel() // Existing view model for user filaments
    @StateObject private var colorLibrary = ColorLibraryViewModel() // Existing view model for legacy colors

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
                .environmentObject(filamentLibraryViewModel) // Add the new library VM
                .environmentObject(filamentViewModel) // Keep the existing filament VM
                .environmentObject(colorLibrary) // Keep the existing color library VM
                .modelContainer(container) // Apply the configured container
        }
    }
}
