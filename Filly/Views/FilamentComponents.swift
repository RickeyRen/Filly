import SwiftUI

// 3D线材卷模型 - 精细优化设计
public struct FilamentReelView: View {
    let colors: [Color] // 修改为接收颜色数组
    @State private var rotationDegree: Double = 0
    @Environment(\.colorScheme) private var colorScheme // 添加环境变量获取当前颜色模式
    
    public init(colors: [Color]) { // 修改初始化方法
        self.colors = colors.isEmpty ? [Color.gray] : colors // 确保至少有一种颜色
    }
    
    // 单色初始化兼容
    public init(color: Color) {
        self.init(colors: [color])
    }
    
    // 计算主色调，用于对比色计算等
    private var primaryColor: Color {
        // 可以选择数组中的第一个颜色，或者计算平均色等
        colors.first ?? .gray
    }
    
    public var body: some View {
        ZStack {
            // 外部圆环 - 使用渐变填充
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: colors + [colors.first ?? .gray]), // 循环渐变
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    )
                )
                .frame(width: 76, height: 76)
            
            // 耗材线材质感 - 使用同心圆模拟缠绕的耗材线 - 增强线条对比度
            ForEach(0..<8) { i in
                let radius = 20.0 + CGFloat(i) * 3.0
                let rotationSpeed = i % 2 == 0 ? 1.0 : -0.85
                let rotationOffset = Double(i) * 45 // 错开初始角度
                
                // 主线条 - 增强对比度和可见性
                Circle()
                    .trim(from: i % 3 == 0 ? 0.0 : 0.03, to: i % 4 == 0 ? 0.97 : 1.0) // 添加间隙使旋转更明显
                    .stroke(
                        i % 2 == 0 ? 
                            getEnhancedContrastColor(for: primaryColor, index: i) : // 使用主色调计算对比色
                            (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7)), // 根据模式设置虚线颜色
                        style: StrokeStyle(
                            lineWidth: 1.2 + (CGFloat(7-i) * 0.05),
                            lineCap: .round,
                            lineJoin: .round,
                            dash: i % 2 == 0 ? [] : [3, 3] // 偶数圆为实线，奇数圆为虚线
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(Angle(degrees: rotationOffset + rotationDegree * rotationSpeed))
            }
            
            // 添加非对称标记，使旋转更加明显
            ForEach(0..<3) { i in
                let angle = Double(i) * 120.0
                let radius = 32.0
                
                // 小圆点标记 - 根据模式调整颜色
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘 - 加粗边缘线
            Circle()
                .stroke(
                    getStrongContrastColor(for: primaryColor), // 使用主色调计算对比色
                    lineWidth: 2.0
                )
                .frame(width: 27, height: 27)
            
            // 中心孔 - 替换为三等分圆环
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
                            startRadius: 5,
                            endRadius: 15
                        )
                    )
                    .frame(width: 25, height: 25)
                
                // 三等分圆环 - 每段80度，间隔40度
                ForEach(0..<3) { i in
                    let startAngle = Double(i) * 120 + 20 // 起始角度，加上20度偏移
                    let endAngle = startAngle + 80 // 结束角度，覆盖80度
                    
                    Circle()
                        .trim(from: startAngle / 360, to: endAngle / 360)
                        .stroke(
                            Color.black.opacity(0.8),
                            style: StrokeStyle(lineWidth: 4.0, lineCap: .round)
                        )
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 反向旋转，速度比外层快50%
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 1.0, x: 0, y: 0.5)
            
            // 顶部高光 - 增强塑料质感，改为非对称高光并旋转
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(
                    Color.white.opacity(0.5),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 44, height: 44)
                .rotationEffect(Angle(degrees: -20 + rotationDegree * 0.5))
                .offset(y: -7)
                .blur(radius: 3)
                
            // 最外侧边框 - 使用更清晰的边框
            Circle()
                .stroke(
                    getStrongBorderColor(for: primaryColor), // 使用主色调计算对比色
                    lineWidth: 1.2
                )
                .frame(width: 76, height: 76)
        }
        .frame(width: 85, height: 85)
        .modifier(BreathingEffect())
        .onAppear {
            // 使用无限循环动画，避免重新开始感
            let baseAnimation = Animation.linear(duration: 24)
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
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
    
    // 获取中心孔边缘的强对比色
    private func getStrongContrastColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        if brightness > 0.6 {
            // 亮色背景
            return Color.black.opacity(0.7)
        } else {
            // 暗色背景
            return Color.white.opacity(0.8)
        }
    }
}

// 颜色处理辅助函数
func getColorBrightness(_ color: Color) -> Double {
    // 近似估计颜色亮度 (简化版)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    #if os(iOS)
    let uiColor = UIColor(color)
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    #elseif os(macOS)
    let nsColor = NSColor(color)
    nsColor.usingColorSpace(.genericRGB)?.getRed(&red, green: &green, blue: &blue, alpha: nil)
    #endif
    
    // 使用感知亮度公式 (人眼对绿色更敏感)
    return Double(0.299 * red + 0.587 * green + 0.114 * blue)
}

func lighten(_ color: Color, by percentage: Double) -> Color {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    #if os(iOS)
    let uiColor = UIColor(color)
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #elseif os(macOS)
    let nsColor = NSColor(color)
    nsColor.usingColorSpace(.genericRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #endif
    
    // 向白色方向移动
    return Color(
        red: min(red + CGFloat(percentage), 1.0),
        green: min(green + CGFloat(percentage), 1.0),
        blue: min(blue + CGFloat(percentage), 1.0),
        opacity: Double(alpha)
    )
}

func darken(_ color: Color, by percentage: Double) -> Color {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    #if os(iOS)
    let uiColor = UIColor(color)
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #elseif os(macOS)
    let nsColor = NSColor(color)
    nsColor.usingColorSpace(.genericRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #endif
    
    // 向黑色方向移动
    return Color(
        red: max(red - CGFloat(percentage), 0.0),
        green: max(green - CGFloat(percentage), 0.0),
        blue: max(blue - CGFloat(percentage), 0.0),
        opacity: Double(alpha)
    )
}

// 迷你线材卷模型 - 用于颜色选择器和添加耗材视图
public struct MiniFilamentReelView: View {
    let color: Color
    
    public init(color: Color) {
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            // 使用FilamentReelView替代SimpleFillamentReel2D
            FilamentReelView(color: color)
                .scaleEffect(0.7)  // 缩小到适合UI的大小
        }
        .frame(width: 55, height: 55)
        .clipShape(Circle())  // 确保内容不会溢出边界
    }
}

// 呼吸效果组件
struct BreathingEffect: ViewModifier {
    // 使用多个状态变量来创建更平滑的循环
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.015
    @State private var currentScale: CGFloat = 1.0
    @State private var animationPhase = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(currentScale)
            .onAppear {
                // 初始化状态
                currentScale = scale1
                
                // 启动第一阶段动画
                startNextAnimationPhase()
            }
    }
    
    private func startNextAnimationPhase() {
        let duration = 6.0 // 每阶段的持续时间
        
        // 根据当前阶段决定动画目标
        switch animationPhase {
        case 0:
            withAnimation(Animation.easeInOut(duration: duration)) {
                currentScale = scale2
            }
        case 1:
            withAnimation(Animation.easeInOut(duration: duration)) {
                currentScale = scale1
            }
        default:
            break
        }
        
        // 安排下一阶段
        DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.05) {
            // 在当前动画即将完成时启动下一阶段，以实现无缝过渡
            animationPhase = (animationPhase + 1) % 2
            startNextAnimationPhase()
        }
    }
}
