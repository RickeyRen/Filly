import SwiftUI

// 跨平台颜色兼容工具，用于处理iOS和macOS系统颜色的差异
enum SystemColorCompatibility {
    // 系统背景色
    static var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    // 次级系统背景色
    static var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    // 三级系统背景色
    static var tertiarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.textBackgroundColor)
        #endif
    }
    
    // 系统填充色
    static var systemFill: Color {
        #if os(iOS)
        return Color(UIColor.systemFill)
        #elseif os(macOS)
        return Color(NSColor.underPageBackgroundColor)
        #endif
    }
    
    // 获取平台兼容的系统颜色
    static func getPlatformColor(_ name: String) -> Color {
        #if os(iOS)
        switch name {
        case "systemBackground": return Color(UIColor.systemBackground)
        case "secondarySystemBackground": return Color(UIColor.secondarySystemBackground)
        case "tertiarySystemBackground": return Color(UIColor.tertiarySystemBackground)
        case "systemFill": return Color(UIColor.systemFill)
        default: return Color.gray.opacity(0.2)
        }
        #elseif os(macOS)
        switch name {
        case "systemBackground": return Color(NSColor.windowBackgroundColor)
        case "secondarySystemBackground": return Color(NSColor.controlBackgroundColor)
        case "tertiarySystemBackground": return Color(NSColor.textBackgroundColor)
        case "systemFill": return Color(NSColor.underPageBackgroundColor)
        default: return Color.gray.opacity(0.2)
        }
        #endif
    }
}

// 跨平台屏幕尺寸兼容工具
enum ScreenSizeCompatibility {
    // 主屏幕宽度
    static var mainWidth: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.width
        #elseif os(macOS)
        return NSScreen.main?.frame.width ?? 1200
        #endif
    }
    
    // 主屏幕高度
    static var mainHeight: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.height
        #elseif os(macOS)
        return NSScreen.main?.frame.height ?? 800
        #endif
    }
} 