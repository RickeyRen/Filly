import SwiftUI

// 自定义修饰符，处理可选的ColorScheme
struct PreferredColorSchemeModifier: ViewModifier {
    let colorScheme: ColorScheme?
    
    func body(content: Content) -> some View {
        if let scheme = colorScheme {
            content.preferredColorScheme(scheme)
        } else {
            content
        }
    }
}

// 扩展View，添加便捷方法
extension View {
    func preferredColorSchemeIfAvailable(_ colorScheme: ColorScheme?) -> some View {
        self.modifier(PreferredColorSchemeModifier(colorScheme: colorScheme))
    }
} 