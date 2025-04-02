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
    // 使用willSet而不是didSet，避免触发不必要的UI重建
    @Published var selectedTheme: ThemeMode {
        willSet {
            if newValue != selectedTheme {
                UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
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
    
    // 安全应用主题而不导致上下文重置
    func applyTheme() {
        // 通过NotificationCenter发送通知，而不是直接修改Published属性
        // 这样可以减少视图层次结构的重建次数
        NotificationCenter.default.post(name: .themeChanged, object: selectedTheme)
    }
}

// 主题变更通知名称
extension Notification.Name {
    static let themeChanged = Notification.Name("com.filly.themeChanged")
} 