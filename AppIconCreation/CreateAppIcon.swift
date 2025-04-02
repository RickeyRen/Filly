import SwiftUI
#if os(macOS)
import AppKit
#endif

struct AppIconGenerator: View {
    let iconSize: CGFloat = 1024
    let color: Color = .blue
    
    var body: some View {
        ZStack {
            // 背景
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.95),
                            Color(red: 0.97, green: 0.97, blue: 0.97)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: iconSize/2
                    )
                )
                .frame(width: iconSize, height: iconSize)
            
            // 耗材线材盘图标 - 放大版
            ZStack {
                // 外部圆环 - 采用渐变填充增强立体感
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                lighten(color, by: 0.1),
                                color,
                                darken(color, by: 0.2)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: iconSize * 0.35
                        )
                    )
                    .frame(width: iconSize * 0.75, height: iconSize * 0.75)
                
                // 耗材线材质感 - 使用同心圆模拟缠绕的耗材线
                ForEach(0..<8) { i in
                    let radius = iconSize * 0.2 + CGFloat(i) * (iconSize * 0.03)
                    
                    // 主线条
                    Circle()
                        .trim(from: i % 3 == 0 ? 0.0 : 0.03, to: i % 4 == 0 ? 0.97 : 1.0) // 添加间隙使旋转更明显
                        .stroke(
                            i % 2 == 0 ? 
                                getEnhancedContrastColor(for: color, index: i) : 
                                Color.white.opacity(0.8),
                            style: StrokeStyle(
                                lineWidth: iconSize * 0.01 + (CGFloat(7-i) * iconSize * 0.0005),
                                lineCap: .round,
                                lineJoin: .round,
                                dash: i % 2 == 0 ? [] : [iconSize * 0.03, iconSize * 0.03]
                            )
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .rotationEffect(Angle(degrees: Double(i) * 45))
                }
                
                // 添加非对称标记
                ForEach(0..<3) { i in
                    let angle = Double(i) * 120.0
                    let radius = iconSize * 0.32
                    
                    // 小圆点标记
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: iconSize * 0.02, height: iconSize * 0.02)
                        .offset(
                            x: CGFloat(cos(Angle(degrees: angle).radians) * radius),
                            y: CGFloat(sin(Angle(degrees: angle).radians) * radius)
                        )
                }
                
                // 中心孔周围的边缘
                Circle()
                    .stroke(
                        getStrongContrastColor(for: color),
                        lineWidth: iconSize * 0.02
                    )
                    .frame(width: iconSize * 0.25, height: iconSize * 0.25)
                
                // 中心孔
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
                                startRadius: 5,
                                endRadius: iconSize * 0.1
                            )
                        )
                        .frame(width: iconSize * 0.24, height: iconSize * 0.24)
                    
                    // 三等分圆环
                    ForEach(0..<3) { i in
                        let startAngle = Double(i) * 120 + 20
                        let endAngle = startAngle + 80
                        
                        Circle()
                            .trim(from: startAngle / 360, to: endAngle / 360)
                            .stroke(
                                Color.black.opacity(0.8),
                                style: StrokeStyle(lineWidth: iconSize * 0.04, lineCap: .round)
                            )
                            .frame(width: iconSize * 0.2, height: iconSize * 0.2)
                            .rotationEffect(Angle(degrees: -90))
                    }
                }
                .shadow(color: Color.black.opacity(0.15), radius: iconSize * 0.01, x: 0, y: iconSize * 0.005)
                
                // 顶部高光
                Circle()
                    .trim(from: 0.0, to: 0.3)
                    .stroke(
                        Color.white.opacity(0.5),
                        style: StrokeStyle(lineWidth: iconSize * 0.2, lineCap: .round)
                    )
                    .frame(width: iconSize * 0.44, height: iconSize * 0.44)
                    .rotationEffect(Angle(degrees: -20))
                    .offset(y: -iconSize * 0.07)
                    .blur(radius: iconSize * 0.03)
                
                // 最外侧边框
                Circle()
                    .stroke(
                        getStrongBorderColor(for: color),
                        lineWidth: iconSize * 0.01
                    )
                    .frame(width: iconSize * 0.75, height: iconSize * 0.75)
            }
            .frame(width: iconSize * 0.8, height: iconSize * 0.8)
            
            // 阴影效果
            Circle()
                .fill(Color.clear)
                .frame(width: iconSize * 0.75, height: iconSize * 0.75)
                .shadow(color: Color.black.opacity(0.2), radius: iconSize * 0.04, x: 0, y: iconSize * 0.01)
        }
        .frame(width: iconSize, height: iconSize)
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

// 预览生成器
struct AppIconGeneratorPreview: PreviewProvider {
    static var previews: some View {
        AppIconGenerator()
            .previewLayout(.fixed(width: 1024, height: 1024))
    }
}

// 生成并保存图标到文件
struct IconCreator {
    static func createIcon() {
        // 创建输出目录
        let outputPath = "/Volumes/Repository/Filly/AppIconCreation/IconOutput"
        try? FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
        
        let iconView = AppIconGenerator()
        
        // 定义图标尺寸
        let sizes = [
            // iOS
            (name: "ios", size: 1024),
            
            // macOS
            (name: "mac16", size: 16),
            (name: "mac32", size: 32),
            (name: "mac64", size: 64),
            (name: "mac128", size: 128),
            (name: "mac256", size: 256),
            (name: "mac512", size: 512),
            (name: "mac1024", size: 1024)
        ]
        
        // 创建渲染器
        let renderer = ImageRenderer(content: iconView)
        
        // 设置渲染属性 - 确保完全不透明
        renderer.isOpaque = true
        
        // 渲染并保存每个尺寸的图标
        for (name, size) in sizes {
            let scaledView = iconView.frame(width: CGFloat(size), height: CGFloat(size))
            let scaledRenderer = ImageRenderer(content: scaledView)
            scaledRenderer.isOpaque = true
            
            #if os(macOS)
            if let nsImage = scaledRenderer.nsImage {
                let filename = "\(outputPath)/AppIcon-\(name)-\(size).png"
                if let tiffData = nsImage.tiffRepresentation {
                    if let bitmap = NSBitmapImageRep(data: tiffData) {
                        if let pngData = bitmap.representation(using: .png, properties: [:]) {
                            do {
                                try pngData.write(to: URL(fileURLWithPath: filename))
                                print("Saved \(filename)")
                            } catch {
                                print("Error saving \(filename): \(error)")
                            }
                        }
                    }
                }
            }
            #endif
        }
        
        print("App icons created in \(outputPath)")
        
        // 自动更新AppIcon.appiconset内容
        updateAppIconset(sourcePath: outputPath)
    }
    
    static func updateAppIconset(sourcePath: String) {
        // AppIcon.appiconset路径
        let appIconsetPath = "/Volumes/Repository/Filly/Assets.xcassets/AppIcon.appiconset"
        
        // 复制生成的图标到AppIcon.appiconset
        let fileManager = FileManager.default
        
        // 创建目录映射
        let iconMapping = [
            "AppIcon-mac16-16.png": "mac16x16.png",
            "AppIcon-mac32-32.png": "mac16x16@2x.png",
            "AppIcon-mac32-32.png": "mac32x32.png",
            "AppIcon-mac64-64.png": "mac32x32@2x.png",
            "AppIcon-mac128-128.png": "mac128x128.png",
            "AppIcon-mac256-256.png": "mac128x128@2x.png",
            "AppIcon-mac256-256.png": "mac256x256.png",
            "AppIcon-mac512-512.png": "mac256x256@2x.png",
            "AppIcon-mac512-512.png": "mac512x512.png",
            "AppIcon-mac1024-1024.png": "mac512x512@2x.png",
            "AppIcon-ios-1024.png": "ios.png"
        ]
        
        // 复制文件
        for (source, destination) in iconMapping {
            let sourceURL = URL(fileURLWithPath: "\(sourcePath)/\(source)")
            let destURL = URL(fileURLWithPath: "\(appIconsetPath)/\(destination)")
            
            do {
                if fileManager.fileExists(atPath: destURL.path) {
                    try fileManager.removeItem(at: destURL)
                }
                try fileManager.copyItem(at: sourceURL, to: destURL)
                print("Copied \(source) to \(destination)")
            } catch {
                print("Error copying \(source) to \(destination): \(error)")
            }
        }
        
        // 更新Contents.json
        updateContentsJson(appIconsetPath: appIconsetPath)
        
        print("AppIcon.appiconset updated successfully!")
    }
    
    static func updateContentsJson(appIconsetPath: String) {
        let contentsJsonPath = "\(appIconsetPath)/Contents.json"
        
        // 创建新的Contents.json内容
        let contentsJson = """
        {
          "images" : [
            {
              "filename" : "ios.png",
              "idiom" : "universal",
              "platform" : "ios",
              "size" : "1024x1024"
            },
            {
              "filename" : "mac16x16.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "16x16"
            },
            {
              "filename" : "mac16x16@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "16x16"
            },
            {
              "filename" : "mac32x32.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "32x32"
            },
            {
              "filename" : "mac32x32@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "32x32"
            },
            {
              "filename" : "mac128x128.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "128x128"
            },
            {
              "filename" : "mac128x128@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "128x128"
            },
            {
              "filename" : "mac256x256.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "256x256"
            },
            {
              "filename" : "mac256x256@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "256x256"
            },
            {
              "filename" : "mac512x512.png",
              "idiom" : "mac",
              "scale" : "1x",
              "size" : "512x512"
            },
            {
              "filename" : "mac512x512@2x.png",
              "idiom" : "mac",
              "scale" : "2x",
              "size" : "512x512"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        
        do {
            try contentsJson.write(to: URL(fileURLWithPath: contentsJsonPath), atomically: true, encoding: .utf8)
            print("Updated Contents.json")
        } catch {
            print("Error updating Contents.json: \(error)")
        }
    }
}

// 主入口 - 命令行工具
@main
struct AppIconGenerator_CommandLine {
    static func main() {
        print("Generating app icons for Filly...")
        IconCreator.createIcon()
        print("Done!")
    }
} 