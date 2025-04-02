import SwiftUI
// 注：由于需要使用FilamentComponents中定义的辅助函数
// 包括BreathingEffect、getColorBrightness、lighten和darken函数

struct FilamentReelView: View {
    let color: Color
    let gradient: Gradient?
    let gradientType: Int
    @State private var rotationDegree: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    init(color: Color, gradient: Gradient? = nil, gradientType: Int = 0) {
        self.color = color
        self.gradient = gradient
        self.gradientType = gradientType
    }
    
    var body: some View {
        ZStack {
            // 外部圆环 - 采用渐变填充增强立体感
            Circle()
                .fill(getFilamentFill())
                .frame(width: 76, height: 76)
            
            // 耗材线材质感 - 使用同心圆模拟缠绕的耗材线
            ForEach(0..<8) { i in
                let radius = 20.0 + CGFloat(i) * 3.0
                let rotationSpeed = i % 2 == 0 ? 1.0 : -0.85
                let rotationOffset = Double(i) * 45 // 错开初始角度
                
                // 主线条
                Circle()
                    .trim(from: i % 3 == 0 ? 0.0 : 0.03, to: i % 4 == 0 ? 0.97 : 1.0)
                    .stroke(
                        i % 2 == 0 ? 
                            getEnhancedContrastColor(for: color, index: i) : 
                            (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7)),
                        style: StrokeStyle(
                            lineWidth: 1.2 + (CGFloat(7-i) * 0.05),
                            lineCap: .round,
                            lineJoin: .round,
                            dash: i % 2 == 0 ? [] : [3, 3]
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(Angle(degrees: rotationOffset + rotationDegree * rotationSpeed))
            }
            
            // 添加非对称标记，使旋转更加明显
            ForEach(0..<3) { i in
                let angle = Double(i) * 120.0
                let radius = 32.0
                
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.2).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘
            Circle()
                .stroke(
                    getStrongContrastColor(for: color),
                    lineWidth: 2.0
                )
                .frame(width: 27, height: 27)
            
            // 中心孔 - 三等分圆环
            ZStack {
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
                
                ForEach(0..<3) { i in
                    let startAngle = Double(i) * 120 + 20
                    let endAngle = startAngle + 80
                    
                    Circle()
                        .trim(from: startAngle / 360, to: endAngle / 360)
                        .stroke(
                            Color.black.opacity(0.8),
                            style: StrokeStyle(lineWidth: 4.0, lineCap: .round)
                        )
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5))
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 1.0, x: 0, y: 0.5)
            
            // 顶部高光
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
                
            // 最外侧边框
            Circle()
                .stroke(
                    getStrongBorderColor(for: color),
                    lineWidth: 1.2
                )
                .frame(width: 76, height: 76)
        }
        .frame(width: 85, height: 85)
        .modifier(BreathingEffect())
        .onAppear {
            // 使用无限循环动画
            let baseAnimation = Animation.linear(duration: 24)
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
                rotationDegree = 360
            }
        }
    }
    
    // 获取视觉效果填充
    private func getFilamentFill() -> some ShapeStyle {
        if let gradient = gradient, gradientType > 0 {
            switch gradientType {
            case 1: // horizontal
                return AnyShapeStyle(LinearGradient(
                    gradient: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            case 2: // vertical
                return AnyShapeStyle(LinearGradient(
                    gradient: gradient,
                    startPoint: .top,
                    endPoint: .bottom
                ))
            case 3: // diagonal
                return AnyShapeStyle(LinearGradient(
                    gradient: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            case 4: // radial
                return AnyShapeStyle(RadialGradient(
                    gradient: gradient,
                    center: .center,
                    startRadius: 0,
                    endRadius: 40
                ))
            case 5, 6: // multiColor or rainbow
                return AnyShapeStyle(AngularGradient(
                    gradient: gradient,
                    center: .center
                ))
            default:
                return AnyShapeStyle(RadialGradient(
                    gradient: Gradient(colors: [
                        lighten(color, by: 0.1),
                        color,
                        darken(color, by: 0.2)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 38
                ))
            }
        } else {
            // 单色时使用径向渐变增强立体感
            return AnyShapeStyle(RadialGradient(
                gradient: Gradient(colors: [
                    lighten(color, by: 0.1),
                    color,
                    darken(color, by: 0.2)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 38
            ))
        }
    }
    
    // 获取与背景色形成明显对比的增强线条颜色
    private func getEnhancedContrastColor(for backgroundColor: Color, index: Int) -> Color {
        // 估算背景色亮度
        let brightness = getColorBrightness(backgroundColor)
        
        // 交替使用基于亮度的不同对比方案
        if index % 2 == 0 {
            if brightness > 0.7 {
                return darken(backgroundColor, by: 0.5).opacity(0.9)
            } else if brightness > 0.4 {
                return lighten(backgroundColor, by: 0.35).opacity(0.9)
            } else {
                return lighten(backgroundColor, by: 0.6).opacity(0.9)
            }
        } else {
            if brightness > 0.7 {
                return darken(backgroundColor, by: 0.3).opacity(0.9)
            } else if brightness > 0.4 {
                return darken(backgroundColor, by: 0.25).opacity(0.9)
            } else {
                return lighten(backgroundColor, by: 0.4).opacity(0.9)
            }
        }
    }
    
    // 获取强对比边框颜色
    private func getStrongBorderColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        if brightness > 0.8 {
            return darken(backgroundColor, by: 0.7).opacity(0.9)
        } else if brightness > 0.6 {
            return darken(backgroundColor, by: 0.5).opacity(0.9)
        } else if brightness > 0.4 {
            return lighten(backgroundColor, by: 0.4).opacity(0.9)
        } else if brightness > 0.2 {
            return lighten(backgroundColor, by: 0.6).opacity(0.9)
        } else {
            return lighten(backgroundColor, by: 0.8).opacity(0.9)
        }
    }
    
    // 获取中心孔边缘的强对比色
    private func getStrongContrastColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        if brightness > 0.6 {
            return Color.black.opacity(0.7)
        } else {
            return Color.white.opacity(0.8)
        }
    }
} 