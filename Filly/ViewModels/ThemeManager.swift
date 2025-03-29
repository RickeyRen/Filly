import SwiftUI
import Combine

// 主题模式枚举
enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "跟随系统"
    case light = "亮色模式"
    case dark = "暗黑模式"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "iphone.circle"
        case .light: return "sun.max.circle"
        case .dark: return "moon.circle"
        }
    }
}

// 主题管理器
class ThemeManager: ObservableObject {
    @Published var selectedTheme: ThemeMode {
        didSet {
            if oldValue != selectedTheme { // 只有当值确实发生变化时才执行
                UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
                // 发布通知，以便UI响应主题变化
                NotificationCenter.default.post(name: .themeChanged, object: nil)
            }
        }
    }
    
    init() {
        // 从UserDefaults读取保存的主题设置，默认跟随系统
        if let savedThemeValue = UserDefaults.standard.string(forKey: "selectedTheme"),
           let savedTheme = ThemeMode(rawValue: savedThemeValue) {
            self.selectedTheme = savedTheme
        } else {
            self.selectedTheme = .system
        }
    }
}

// 主题变更通知名称
extension Notification.Name {
    static let themeChanged = Notification.Name("com.filly.themeChanged")
} 