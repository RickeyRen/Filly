import SwiftUI

// 简化的2D耗材盘图标 - 精细优化设计
public struct SimpleFillamentReel2D: View {
    let color: Color
    @State private var rotationDegree: Double = 0
    
    public init(color: Color) {
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            // 外部圆环 - 采用渐变填充增强立体感
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(1.0),
                            darken(color, by: 0.2)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            // 耗材线材质感 - 使用同心圆模拟缠绕的耗材线 - 增强线条可见性
            ForEach(0..<5) { i in
                let radius = 14.0 + CGFloat(i) * 3.5
                let rotationSpeed = i % 2 == 0 ? 1.0 : -0.85
                let rotationOffset = Double(i) * 72 // 错开初始角度
                
                // 主线条 - 增强对比度和可见性
                Circle()
                    .trim(from: i % 2 == 0 ? 0.0 : 0.05, to: i % 3 == 0 ? 0.95 : 1.0) // 添加间隙使旋转更明显
                    .stroke(
                        getEnhancedContrastColor(for: color, index: i),
                        style: StrokeStyle(
                            lineWidth: 1.2 + (CGFloat(4-i) * 0.1),
                            lineCap: .round,
                            lineJoin: .round,
                            dash: i % 2 == 0 ? [] : [3, 3] // 偶数圆为实线，奇数圆为虚线
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(Angle(degrees: rotationOffset + rotationDegree * rotationSpeed))
            }
            
            // 添加非对称标记，使旋转更加明显
            ForEach(0..<2) { i in
                let angle = Double(i) * 180.0
                let radius = 20.0
                
                // 小圆点标记
                Circle()
                    .fill(color == .white ? Color.gray : .white)
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘 - 加粗边缘线
            Circle()
                .stroke(
                    getStrongContrastColor(for: color),
                    lineWidth: 1.5
                )
                .frame(width: 18, height: 18)
            
            // 中心孔 - 替换为三等分的中间有空隙圆环
            ZStack {
                // 背景圆 - 提供白色背景
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.95)
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 7
                        )
                    )
                    .frame(width: 15, height: 15)
                
                // 三等分圆环 - 每段80度，间隔40度
                ForEach(0..<3) { i in
                    let startAngle = Double(i) * 120 + 20 // 起始角度，加上20度偏移
                    let endAngle = startAngle + 80 // 结束角度，覆盖80度
                    
                    Circle()
                        .trim(from: startAngle / 360, to: endAngle / 360)
                        .stroke(
                            Color.black.opacity(0.8),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .frame(width: 12, height: 12)
                        .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 反向旋转，速度比外层快50%
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.4)
            
            // 顶部高光 - 增强塑料质感，改为非对称高光并旋转
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(
                    Color.white.opacity(0.5),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: -20 + rotationDegree * 0.5))
                .offset(y: -6)
                .blur(radius: 3.0)
                
            // 最外侧边框 - 使用更清晰的边框
            Circle()
                .stroke(
                    getStrongBorderColor(for: color),
                    lineWidth: 1.0
                )
                .frame(width: 50, height: 50)
        }
        .modifier(BreathingEffect())
        .onAppear {
            withAnimation(Animation.linear(duration: 24).repeatForever(autoreverses: false)) {
                rotationDegree = 360
            }
        }
    }
    
    // 获取与背景色形成明显对比的增强线条颜色
    private func getEnhancedContrastColor(for backgroundColor: Color, index: Int) -> Color {
        // 估算背景色亮度
        let brightness = getColorBrightness(backgroundColor)
        
        // 交替使用基于亮度的不同对比方案，增加线条之间的区分度
        if index % 2 == 0 {
            // 偶数索引的线条
            if brightness > 0.7 {
                // 亮色背景使用较深对比色
                return darken(backgroundColor, by: 0.5).opacity(0.9)
            } else if brightness > 0.4 {
                // 中等亮度背景使用适度对比色 
                return lighten(backgroundColor, by: 0.35).opacity(0.9)
            } else {
                // 暗色背景使用明显的亮色
                return lighten(backgroundColor, by: 0.6).opacity(0.9)
            }
        } else {
            // 奇数索引的线条，使用不同强度
            if brightness > 0.7 {
                // 亮色背景
                return darken(backgroundColor, by: 0.3).opacity(0.9)
            } else if brightness > 0.4 {
                // 中等亮度背景
                return darken(backgroundColor, by: 0.25).opacity(0.9)
            } else {
                // 暗色背景
                return lighten(backgroundColor, by: 0.4).opacity(0.9)
            }
        }
    }
    
    // 获取强对比边框颜色，确保边框在任何背景色上都清晰可见
    private func getStrongBorderColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        // 为所有亮度范围使用更强对比度的边框
        if brightness > 0.8 {
            // 非常亮的背景色
            return darken(backgroundColor, by: 0.7).opacity(0.9)
        } else if brightness > 0.6 {
            // 亮色背景
            return darken(backgroundColor, by: 0.5).opacity(0.9)
        } else if brightness > 0.4 {
            // 中等亮度背景
            return lighten(backgroundColor, by: 0.4).opacity(0.9)
        } else if brightness > 0.2 {
            // 中暗背景
            return lighten(backgroundColor, by: 0.6).opacity(0.9)
        } else {
            // 非常暗的背景
            return lighten(backgroundColor, by: 0.8).opacity(0.9)
        }
    }
    
    // 获取三等分圆环的颜色
    private func getThreePartRingColor(for backgroundColor: Color, index: Int) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        // 根据背景亮度和部分索引选择不同的颜色
        switch index {
        case 0: // 第一部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.4).opacity(0.9) : 
                lighten(backgroundColor, by: 0.5).opacity(0.9)
        case 1: // 第二部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.6).opacity(0.9) : 
                lighten(backgroundColor, by: 0.7).opacity(0.9)
        case 2: // 第三部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.5).opacity(0.9) : 
                lighten(backgroundColor, by: 0.6).opacity(0.9)
        default:
            return Color.gray
        }
    }
    
    // 获取中心孔边缘的强对比色
    private func getStrongContrastColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        if brightness > 0.5 {
            // 亮色背景使用深色对比
            return darken(backgroundColor, by: 0.6).opacity(0.9)
        } else {
            // 暗色背景使用亮色对比
            return lighten(backgroundColor, by: 0.7).opacity(0.9)
        }
    }
    
    // 使颜色变暗一定程度
    private func darken(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #endif
    }
    
    // 使颜色变亮一定程度
    private func lighten(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #endif
    }
    
    // 估算颜色亮度 (0-1范围)
    private func getColorBrightness(_ color: Color) -> CGFloat {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        // 使用亮度公式: 0.299R + 0.587G + 0.114B
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}

// 呼吸效果修饰器 - 用于添加微妙的缩放动画
struct BreathingEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 12.0).repeatForever(autoreverses: true)) {
                    scale = 1.03
                }
            }
    }
}

// 迷你线材卷模型 - 用于颜色选择器和添加耗材视图 (简化2D版本)
public struct MiniFilamentReelView: View {
    let color: Color
    
    public init(color: Color) {
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            // 简单耗材盘2D图标
            SimpleFillamentReel2D(color: color)
        }
        .frame(width: 55, height: 55)
    }
}
