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
            // 最外侧边框 - 使用更清晰的边框
            Circle()
                .stroke(
                    getStrongBorderColor(for: color),
                    lineWidth: 1.2
                )
                .frame(width: 50, height: 50)

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
