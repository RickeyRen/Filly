import SwiftUI

struct FilamentReelView: View {
    let color: Color
    let gradient: Gradient?
    let gradientType: Int
    
    init(color: Color, gradient: Gradient? = nil, gradientType: Int = 0) {
        self.color = color
        self.gradient = gradient
        self.gradientType = gradientType
    }
    
    var body: some View {
        ZStack {
            // 耗材盘底部
            Circle()
                .fill(getFilamentFill())
                .frame(width: 80, height: 80)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            // 中心孔
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
        }
    }
    
    // 根据是否有渐变返回不同的填充
    private func getFilamentFill() -> some ShapeStyle {
        if let gradient = gradient {
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
                return AnyShapeStyle(color)
            }
        } else {
            return AnyShapeStyle(color)
        }
    }
} 