import Foundation
import SwiftUI

/// 存储所有预设耗材数据的结构体
struct PresetFilamentData {
    
    // 渐变类型
    enum GradientType: Int {
        case none = 0          // 没有渐变（单色）
        case horizontal = 1    // 水平渐变
        case vertical = 2      // 垂直渐变
        case diagonal = 3      // 对角线渐变
        case radial = 4        // 径向渐变
        case multiColor = 5    // 多色渐变（超过两色）
        case rainbow = 6       // 彩虹色
    }
    
    // 颜色属性定义
    struct ColorProperties {
        let name: String
        let code: String?
        let hasSpool: Bool
        let isTransparent: Bool
        let isMetallic: Bool
        
        // 新增渐变相关属性
        let gradientType: GradientType
        let additionalColors: [Color]  // 附加颜色（用于渐变）
        
        init(name: String, 
             code: String? = nil, 
             hasSpool: Bool = true, 
             isTransparent: Bool = false, 
             isMetallic: Bool = false,
             gradientType: GradientType = .none,
             additionalColors: [Color] = []) {
            self.name = name
            self.code = code
            self.hasSpool = hasSpool
            self.isTransparent = isTransparent
            self.isMetallic = isMetallic
            self.gradientType = gradientType
            self.additionalColors = additionalColors
        }
    }
    
    // 材料类型定义
    struct MaterialType {
        let name: String
        let colors: [ColorProperties]
    }
    
    // 品牌定义
    struct Brand {
        let name: String
        let materialTypes: [MaterialType]
    }
    
    // 所有预设品牌数据
    static let brands: [Brand] = [
        // 拓竹 Bambu Lab
        Brand(
            name: "拓竹 Bambu Lab",
            materialTypes: [
                MaterialType(
                    name: "PLA Lite",
                    colors: [
                        // 每种颜色添加含料盘和不含料盘两个版本
                        ColorProperties(name: "黑色", code: "16100", hasSpool: true),
                        ColorProperties(name: "黑色", code: "16100", hasSpool: false),
                        ColorProperties(name: "天蓝色", code: "16600", hasSpool: true),
                        ColorProperties(name: "天蓝色", code: "16600", hasSpool: false),
                        ColorProperties(name: "黄色", code: "16400", hasSpool: true),
                        ColorProperties(name: "黄色", code: "16400", hasSpool: false),
                        ColorProperties(name: "白色", code: "16103", hasSpool: true),
                        ColorProperties(name: "白色", code: "16103", hasSpool: false),
                        ColorProperties(name: "红色", code: "16200", hasSpool: true),
                        ColorProperties(name: "红色", code: "16200", hasSpool: false),
                        ColorProperties(name: "灰色", code: "16101", hasSpool: true),
                        ColorProperties(name: "灰色", code: "16101", hasSpool: false),
                        
                        // 添加一些渐变色示例
                        ColorProperties(
                            name: "渐变红蓝", 
                            code: "16700", 
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [Color.blue]
                        ),
                        ColorProperties(
                            name: "彩虹色", 
                            code: "16800", 
                            hasSpool: true,
                            gradientType: .rainbow,
                            additionalColors: [
                                Color.red, Color.orange, Color.yellow, 
                                Color.green, Color.blue, Color.purple
                            ]
                        )
                    ]
                )
            ]
        ),
        
        // 天瑞 Tinmorry
        Brand(
            name: "天瑞 Tinmorry",
            materialTypes: [
                MaterialType(
                    name: "PETG-ECO",
                    colors: [
                        ColorProperties(name: "亮丽黄"),
                        ColorProperties(name: "咖啡色"),
                        ColorProperties(name: "透明", isTransparent: true),
                        ColorProperties(name: "荧光绿"),
                        ColorProperties(name: "荧光黄"),
                        ColorProperties(name: "红色"),
                        ColorProperties(name: "绿色"),
                        ColorProperties(name: "灰色"),
                        ColorProperties(name: "杏色"),
                        ColorProperties(name: "黑色"),
                        ColorProperties(name: "冷白"),
                        ColorProperties(name: "奶白色"),
                        ColorProperties(name: "米宝白"),
                        ColorProperties(name: "肤色"),
                        ColorProperties(name: "淡灰色"),
                        ColorProperties(name: "夜光绿"),
                        ColorProperties(name: "橙色"),
                        ColorProperties(name: "樱花粉"),
                        ColorProperties(name: "粉色"),
                        ColorProperties(name: "长春花蓝"),
                        ColorProperties(name: "薄荷绿"),
                        ColorProperties(name: "卡特黄"),
                        ColorProperties(name: "天空蓝"),
                        ColorProperties(name: "橄榄绿"),
                        ColorProperties(name: "透明蓝", isTransparent: true),
                        ColorProperties(name: "透明绿", isTransparent: true),
                        ColorProperties(name: "透明红", isTransparent: true),
                        ColorProperties(name: "荧光玫红"),
                        ColorProperties(name: "荧光紫红"),
                        ColorProperties(name: "克莱因蓝"),
                        ColorProperties(name: "金属紫", isMetallic: true),
                        ColorProperties(name: "金属香槟金", isMetallic: true),
                        ColorProperties(name: "金属午夜绿", isMetallic: true),
                        ColorProperties(name: "金属银", isMetallic: true),
                        ColorProperties(name: "金属太空灰", isMetallic: true),
                        ColorProperties(name: "金属铜", isMetallic: true),
                        ColorProperties(name: "金属绿", isMetallic: true),
                        ColorProperties(name: "金属珠光蓝", isMetallic: true),
                        ColorProperties(name: "金属玫瑰金", isMetallic: true),
                        ColorProperties(name: "petg碳纤维黑色"),
                        ColorProperties(name: "PETG碳纤维大理石灰"),
                        ColorProperties(name: "PETG碳纤维咖啡色"),
                        ColorProperties(name: "高速Petg薰衣草紫"),
                        ColorProperties(name: "高速Petg桃红"),
                        ColorProperties(name: "高速Petg黑色"),
                        ColorProperties(name: "高速Petg浅蓝"),
                        ColorProperties(name: "高速Petg冷白"),
                        ColorProperties(name: "Petg大理石花岗岩"),
                        ColorProperties(name: "大理石魔幻棕"),
                        ColorProperties(name: "大理石浅灰"),
                        ColorProperties(name: "大理石白"),
                        ColorProperties(name: "petg大理石魔幻紫"),
                        ColorProperties(name: "petg大理石魔幻蓝"),
                        ColorProperties(name: "Petg大理石魔幻绿"),
                        
                        // 添加渐变色示例
                        ColorProperties(
                            name: "双色渐变黑红", 
                            gradientType: .vertical,
                            additionalColors: [Color.red]
                        ),
                        ColorProperties(
                            name: "三色渐变", 
                            gradientType: .multiColor,
                            additionalColors: [Color.purple, Color.blue]
                        )
                    ]
                )
            ]
        ),
        
        // 易生 eSUN
        Brand(
            name: "易生 eSUN",
            materialTypes: [
                MaterialType(
                    name: "PLA仿丝绸",
                    colors: [
                        // 双色丝绸系列
                        ColorProperties(
                            name: "双色丝绸 金银色",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("银")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 红蓝色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("蓝")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 蓝绿色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("绿")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 红金色",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("金")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 黑金色",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("金")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 黑红色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("红")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 黑绿色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("绿")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 紫金色",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("金")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 红绿色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("绿")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 蓝银色",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("银")]
                        ),
                        ColorProperties(
                            name: "双色丝绸 黑紫色",
                            hasSpool: true,
                            gradientType: .horizontal,
                            additionalColors: [PresetFilamentData.getColor("紫")]
                        ),
                        
                        // 三色丝绸系列
                        ColorProperties(
                            name: "三色丝绸 金红绿",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("红"), 
                                PresetFilamentData.getColor("绿")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 铜紫绿",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("紫"), 
                                PresetFilamentData.getColor("绿")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 金绿黑",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("绿"), 
                                PresetFilamentData.getColor("黑")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 蓝橙绿",
                            hasSpool: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("橙"), 
                                PresetFilamentData.getColor("绿")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 金银铜",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("银"), 
                                PresetFilamentData.getColor("铜")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 红黄蓝",
                            hasSpool: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("黄"), 
                                PresetFilamentData.getColor("蓝")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 红金紫",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("金"), 
                                PresetFilamentData.getColor("紫")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 黑红金",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("红"), 
                                PresetFilamentData.getColor("金")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 红绿蓝",
                            hasSpool: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("绿"), 
                                PresetFilamentData.getColor("蓝")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 蓝红紫",
                            hasSpool: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("红"), 
                                PresetFilamentData.getColor("紫")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 金绿紫",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("绿"), 
                                PresetFilamentData.getColor("紫")
                            ]
                        ),
                        ColorProperties(
                            name: "三色丝绸 金蓝紫",
                            hasSpool: true,
                            isMetallic: true,
                            gradientType: .multiColor,
                            additionalColors: [
                                PresetFilamentData.getColor("蓝"), 
                                PresetFilamentData.getColor("紫")
                            ]
                        )
                    ]
                )
            ]
        ),
        
        // 这里可以添加更多品牌...
        // 例如：易生、Polymaker等
    ]
}

// 颜色辅助函数 - 根据常见颜色名提供标准色值
extension PresetFilamentData {
    // 获取标准颜色
    static func getColor(_ name: String) -> Color {
        let lowerName = name.lowercased()
        if lowerName.contains("黑") { return .black }
        if lowerName.contains("白") { return .white }
        if lowerName.contains("红") { return .red }
        if lowerName.contains("蓝") { return .blue }
        if lowerName.contains("绿") { return .green }
        if lowerName.contains("黄") { return .yellow }
        if lowerName.contains("紫") { return .purple }
        if lowerName.contains("橙") { return .orange }
        if lowerName.contains("金") { return Color(red: 1.0, green: 0.84, blue: 0.0) }
        if lowerName.contains("银") { return Color(white: 0.85) }
        if lowerName.contains("铜") { return Color(red: 0.8, green: 0.5, blue: 0.2) }
        return .gray
    }
} 