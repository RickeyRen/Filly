import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// 系统颜色兼容层，用于在iOS和macOS之间统一颜色
struct SystemColorCompatibility {
    static var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    static var tertiarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.textBackgroundColor)
        #endif
    }
} 