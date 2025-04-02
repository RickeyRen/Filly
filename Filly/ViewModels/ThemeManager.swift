import SwiftUI
import Combine
import SwiftData

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
    // 使用私有属性存储主题，避免直接修改Published属性
    private var _selectedTheme: ThemeMode
    
    // 公开的计算属性，只读
    var selectedTheme: ThemeMode {
        get { _selectedTheme }
    }
    
    // 主题变更指示器
    @Published var themeChangeCounter: Int = 0
    
    init() {
        // 从UserDefaults读取保存的主题设置，默认跟随系统
        if let savedThemeValue = UserDefaults.standard.string(forKey: "selectedTheme"),
           let savedTheme = ThemeMode(rawValue: savedThemeValue) {
            self._selectedTheme = savedTheme
        } else {
            self._selectedTheme = .system
        }
    }
    
    // 安全地更改主题
    func changeTheme(to newTheme: ThemeMode) {
        guard newTheme != _selectedTheme else { return }
        
        // 将主题变更操作放在主队列的下一个周期执行
        // 这样可以确保当前的视图更新周期已经完成
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 保存到UserDefaults
            UserDefaults.standard.set(newTheme.rawValue, forKey: "selectedTheme")
            
            // 更新私有存储
            self._selectedTheme = newTheme
            
            // 通过计数器触发UI更新
            self.themeChangeCounter += 1
            
            // 发送通知
            NotificationCenter.default.post(
                name: .themeChanged,
                object: newTheme,
                userInfo: ["counter": self.themeChangeCounter]
            )
        }
    }
    
    // 获取当前主题的颜色方案
    func currentColorScheme() -> ColorScheme? {
        return _selectedTheme.colorScheme
    }
}

// 主题变更通知名称
extension Notification.Name {
    static let themeChanged = Notification.Name("com.filly.themeChanged")
    static let prepareForThemeChange = Notification.Name("com.filly.prepareForThemeChange")
} 