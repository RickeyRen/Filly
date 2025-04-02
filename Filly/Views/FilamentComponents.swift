import SwiftUI

// 简化的2D耗材盘图标 - 性能优化设计
public struct SimpleFillamentReel2D: View {
    let color: Color
    let colorName: String // 添加颜色名称以便日志
    // 恢复动画状态，提高动画速度
    @State private var rotationDegree: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    // 使用缓存颜色计算结果
    private let cachedColors: CachedColors
    
    public init(color: Color, colorName: String = "") {
        self.color = color
        self.colorName = colorName
        // 初始化时预计算所有颜色值，避免重复计算
        self.cachedColors = CachedColors(baseColor: color, colorName: colorName)
    }
    
    // 缓存的颜色计算结果
    public struct CachedColors {
        public let baseColor: Color
        public let colorName: String
        public let lightenedColor: Color
        public let darkenedColor: Color
        public let borderColor: Color
        public let contrastColors: [Color]
        public let centerContrastColor: Color
        
        public init(baseColor: Color, colorName: String = "") {
            self.baseColor = baseColor
            self.colorName = colorName
            
            // 确保颜色值有效
            let brightness = SimpleFillamentReel2D.getColorBrightness(baseColor)
            
            #if DEBUG
            print("颜色初始化: \(colorName), 亮度: \(brightness)")
            #endif
            
            // 使用更明确的颜色亮化和暗化值，确保有足够的对比度
            self.lightenedColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.2)  // 增加亮化值
            self.darkenedColor = SimpleFillamentReel2D.darken(baseColor, by: 0.3)    // 增加暗化值
            
            // 预计算边框颜色 - 增强边框可见性
            if brightness > 0.8 {
                self.borderColor = SimpleFillamentReel2D.darken(baseColor, by: 0.7).opacity(0.95)
            } else if brightness > 0.6 {
                self.borderColor = SimpleFillamentReel2D.darken(baseColor, by: 0.5).opacity(0.95)
            } else if brightness > 0.4 {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.4).opacity(0.95)
            } else if brightness > 0.2 {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.6).opacity(0.95)
            } else {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.8).opacity(0.95)
            }
            
            // 预计算线条对比色 - 确保有足够的对比度
            var colors: [Color] = []
            for i in 0..<3 {  // 减少预计算的颜色数量
                if i % 2 == 0 {
                    if brightness > 0.7 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.5).opacity(0.95))
                    } else if brightness > 0.4 {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.4).opacity(0.95))
                    } else {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.7).opacity(0.95))
                    }
                } else {
                    if brightness > 0.7 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.4).opacity(0.95))
                    } else if brightness > 0.4 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.3).opacity(0.95))
                    } else {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.5).opacity(0.95))
                    }
                }
            }
            self.contrastColors = colors
            
            // 预计算中心对比色 - 增强对比度
            if brightness > 0.5 {
                self.centerContrastColor = SimpleFillamentReel2D.darken(baseColor, by: 0.6).opacity(0.95)
            } else {
                self.centerContrastColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.7).opacity(0.95)
            }
        }
    }
    
    public var body: some View {
        ZStack {
            // 显示原始颜色和过渡颜色
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(1.0), // 使用原始颜色但完全不透明
                            cachedColors.lightenedColor,
                            color,
                            cachedColors.darkenedColor
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .onAppear {
                    // 打印颜色信息以便调试
                    #if DEBUG
                    let colorInfo = SimpleFillamentReel2D.extractColorValues(color)
                    print("颜色显示: \(colorName), RGB: \(colorInfo.0), \(colorInfo.1), \(colorInfo.2)")
                    #endif
                }
            
            // 使用较少的同心圆减少渲染负担
            CircleWindingsView(colorScheme: colorScheme, rotationDegree: rotationDegree, contrastColors: cachedColors.contrastColors)
            
            // 添加两个标记点，减少动态计算
            ForEach(0..<2) { i in
                let angle = Double(i) * 180.0
                let radius = 20.0
                
                // 小圆点标记
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.0).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.0).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘
            Circle()
                .stroke(cachedColors.centerContrastColor, lineWidth: 1.5)
                .frame(width: 18, height: 18)
            
            // 简化的中心孔
            OptimizedCenterHole(rotationDegree: rotationDegree)
            
            // 顶部高光 - 使用更简单的形状
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: -20 + rotationDegree * 0.5))
                .offset(y: -6)
                .blur(radius: 3.0)
                
            // 最外侧边框 - 增强边框可见性
            Circle()
                .stroke(cachedColors.borderColor, lineWidth: 1.5)  // 增加线宽
                .frame(width: 50, height: 50)
        }
        .onAppear {
            // 使用较短的动画周期提高动画速度
            let baseAnimation = Animation.linear(duration: 20) // 缩短动画周期
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
                rotationDegree = 360
            }
        }
    }
    
    // 静态颜色处理函数，移到外部供CachedColors使用
    static private func lighten(_ color: Color, by amount: CGFloat) -> Color {
        let colorInfo = extractColorValues(color)
        let r = colorInfo.0
        let g = colorInfo.1
        let b = colorInfo.2
        
        // 如果RGB值为0或接近0，则这可能是一个无效的颜色，使用默认颜色
        if r == 0 && g == 0 && b == 0 {
            #if DEBUG
            print("警告: 检测到黑色或无效颜色，使用默认亮色")
            #endif
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        }
        
        return Color(red: min(1, r + amount), 
                     green: min(1, g + amount), 
                     blue: min(1, b + amount))
    }
    
    static private func darken(_ color: Color, by amount: CGFloat) -> Color {
        let colorInfo = extractColorValues(color)
        let r = colorInfo.0
        let g = colorInfo.1
        let b = colorInfo.2
        
        // 如果RGB值为0或接近0，则这可能是一个无效的颜色，使用默认颜色
        if r == 0 && g == 0 && b == 0 {
            #if DEBUG
            print("警告: 检测到黑色或无效颜色，使用默认暗色")
            #endif
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
        
        return Color(red: max(0, r - amount), 
                     green: max(0, g - amount), 
                     blue: max(0, b - amount))
    }
    
    static private func getColorBrightness(_ color: Color) -> CGFloat {
        let colorInfo = extractColorValues(color)
        let r = colorInfo.0
        let g = colorInfo.1
        let b = colorInfo.2
        
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
    
    // 新增：直接提取颜色RGB值的辅助方法
    static func extractColorValues(_ color: Color) -> (CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        #if os(iOS)
        let uiColor = UIColor(color)
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
            return (r, g, b)
        }
        #elseif os(macOS)
        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            return (0.5, 0.5, 0.5) // 默认灰色
        }
        
        if rgbColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
            return (r, g, b)
        }
        #endif
        
        // 如果无法获取RGB值，使用直接初始化Color的方法尝试提取
        // 这是一个回退机制，尝试处理无法正常转换的颜色
        #if DEBUG
        print("警告: 无法提取颜色RGB值，使用默认值")
        #endif
        return (0.5, 0.5, 0.5) // 默认灰色
    }
}

// 提取的同心圆组件 - 优化性能
struct CircleWindingsView: View {
    let colorScheme: ColorScheme
    let rotationDegree: Double
    let contrastColors: [Color]
    
    var body: some View {
        // 减少圆圈数量以提高性能
        ForEach(0..<3) { i in // 只渲染3个圆环
            let radius = 14.0 + CGFloat(i) * 4.5
            let rotationSpeed = i % 2 == 0 ? 1.0 : -0.8 // 提高旋转速度
            let rotationOffset = Double(i) * 72
            
            Circle()
                .trim(from: i % 2 == 0 ? 0.0 : 0.05, to: i % 3 == 0 ? 0.95 : 1.0)
                .stroke(
                    i % 2 == 0 ? 
                        contrastColors[i % contrastColors.count] :
                        (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7)),
                    style: StrokeStyle(
                        lineWidth: 1.2,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: i % 2 == 0 ? [] : [3, 3]
                    )
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(Angle(degrees: rotationOffset + rotationDegree * rotationSpeed))
        }
    }
}

// 提取的中心孔组件 - 优化性能
private struct OptimizedCenterHole: View {
    let rotationDegree: Double
    
    var body: some View {
        ZStack {
            // 背景圆
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
            
            // 三段圆环，较高速度动画
            ForEach(0..<3) { i in
                let startAngle = Double(i) * 120 + 20 // 起始角度，每段相隔120度
                let endAngle = startAngle + 80 // 结束角度，每段覆盖80度
                
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360)
                    .stroke(
                        Color.black.opacity(0.8),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 12, height: 12)
                    .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 提高旋转速度
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.4)
    }
}

// 迷你线材卷模型 - 用于颜色选择器和添加耗材视图 (简化2D版本)
public struct MiniFilamentReelView: View {
    let color: Color
    let colorName: String
    
    public init(color: Color, colorName: String = "") {
        self.color = color
        self.colorName = colorName
    }
    
    public var body: some View {
        ZStack {
            // 简单耗材盘2D图标
            SimpleFillamentReel2D(color: color, colorName: colorName)
                .scaleEffect(0.95)
        }
        .frame(width: 55, height: 55)
        .clipShape(Circle())
    }
}
