import SwiftUI

// 简化的2D耗材盘图标 - 性能优化设计
public struct SimpleFillamentReel2D: View {
    let color: Color
    @State private var rotationDegree: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    // 使用缓存颜色计算结果
    private let cachedColors: CachedColors
    
    public init(color: Color) {
        self.color = color
        // 初始化时预计算所有颜色值，避免重复计算
        self.cachedColors = CachedColors(baseColor: color)
    }
    
    // 缓存的颜色计算结果
    private struct CachedColors {
        let lightenedColor: Color
        let darkenedColor: Color
        let borderColor: Color
        let contrastColors: [Color]
        let centerContrastColor: Color
        
        init(baseColor: Color) {
            let brightness = SimpleFillamentReel2D.getColorBrightness(baseColor)
            
            self.lightenedColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.1)
            self.darkenedColor = SimpleFillamentReel2D.darken(baseColor, by: 0.2)
            
            // 预计算边框颜色
            if brightness > 0.8 {
                self.borderColor = SimpleFillamentReel2D.darken(baseColor, by: 0.7).opacity(0.9)
            } else if brightness > 0.6 {
                self.borderColor = SimpleFillamentReel2D.darken(baseColor, by: 0.5).opacity(0.9)
            } else if brightness > 0.4 {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.4).opacity(0.9)
            } else if brightness > 0.2 {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.6).opacity(0.9)
            } else {
                self.borderColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.8).opacity(0.9)
            }
            
            // 预计算线条对比色
            var colors: [Color] = []
            for i in 0..<5 {
                if i % 2 == 0 {
                    if brightness > 0.7 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.5).opacity(0.9))
                    } else if brightness > 0.4 {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.35).opacity(0.9))
                    } else {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.6).opacity(0.9))
                    }
                } else {
                    if brightness > 0.7 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.3).opacity(0.9))
                    } else if brightness > 0.4 {
                        colors.append(SimpleFillamentReel2D.darken(baseColor, by: 0.25).opacity(0.9))
                    } else {
                        colors.append(SimpleFillamentReel2D.lighten(baseColor, by: 0.4).opacity(0.9))
                    }
                }
            }
            self.contrastColors = colors
            
            // 预计算中心对比色
            if brightness > 0.5 {
                self.centerContrastColor = SimpleFillamentReel2D.darken(baseColor, by: 0.6).opacity(0.9)
            } else {
                self.centerContrastColor = SimpleFillamentReel2D.lighten(baseColor, by: 0.7).opacity(0.9)
            }
        }
    }
    
    public var body: some View {
        ZStack {
            // 背景圆 - 使用缓存的渐变颜色
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
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
            
            // 使用较少的同心圆减少渲染负担
            CircleWindingsView(colorScheme: colorScheme, rotationDegree: rotationDegree, contrastColors: cachedColors.contrastColors)
            
            // 添加两个标记点，使旋转更加明显但减少总数
            ForEach(0..<2) { i in
                let angle = Double(i) * 180.0
                let radius = 20.0
                
                // 小圆点标记
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius)
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
                
            // 最外侧边框
            Circle()
                .stroke(cachedColors.borderColor, lineWidth: 1.0)
                .frame(width: 50, height: 50)
        }
        .modifier(OptimizedBreathingEffect())
        .onAppear {
            // 使用较长的动画周期减少动画计算频率
            let baseAnimation = Animation.linear(duration: 30)
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
                rotationDegree = 360
            }
        }
    }
    
    // 静态颜色处理函数，移到外部供CachedColors使用
    static private func lighten(_ color: Color, by amount: CGFloat) -> Color {
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
    
    static private func darken(_ color: Color, by amount: CGFloat) -> Color {
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
    
    static private func getColorBrightness(_ color: Color) -> CGFloat {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}

// 提取的同心圆组件，减少主视图复杂度
private struct CircleWindingsView: View {
    let colorScheme: ColorScheme
    let rotationDegree: Double
    let contrastColors: [Color]
    
    var body: some View {
        // 减少圆圈数量以提高性能
        ForEach(0..<3) { i in
            let radius = 14.0 + CGFloat(i) * 4.5
            let rotationSpeed = i % 2 == 0 ? 1.0 : -0.85
            let rotationOffset = Double(i) * 72
            
            Circle()
                .trim(from: i % 2 == 0 ? 0.0 : 0.05, to: i % 3 == 0 ? 0.95 : 1.0)
                .stroke(
                    i % 2 == 0 ? 
                        contrastColors[i % contrastColors.count] :
                        (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7)),
                    style: StrokeStyle(
                        lineWidth: 1.2 + (CGFloat(2-i) * 0.1),
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

// 提取的中心孔组件
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
            
            // 简化为两段圆环以减少绘制复杂度
            ForEach(0..<2) { i in
                let startAngle = Double(i) * 180 + 20
                let endAngle = startAngle + 120
                
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360)
                    .stroke(
                        Color.black.opacity(0.8),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 12, height: 12)
                    .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5))
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.4)
    }
}

// 优化的呼吸效果修饰器
struct OptimizedBreathingEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                // 使用较慢的动画周期，减少动画处理负担
                let animation = Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true)
                withAnimation(animation) {
                    scale = 1.02
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
                .scaleEffect(0.95)
        }
        .frame(width: 55, height: 55)
        .clipShape(Circle())
    }
}
