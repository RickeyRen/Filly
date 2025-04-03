import Foundation
import SwiftUI

/// 存储所有预设耗材数据的结构体
struct PresetFilamentData {
    
    // 颜色属性定义
    struct ColorProperties {
        let name: String
        let code: String?
        let hasSpool: Bool
        let isTransparent: Bool
        let isMetallic: Bool
        
        init(name: String, code: String? = nil, hasSpool: Bool = true, isTransparent: Bool = false, isMetallic: Bool = false) {
            self.name = name
            self.code = code
            self.hasSpool = hasSpool
            self.isTransparent = isTransparent
            self.isMetallic = isMetallic
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
                        ColorProperties(name: "灰色", code: "16101", hasSpool: false)
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
                        ColorProperties(name: "Petg大理石魔幻绿")
                    ]
                )
            ]
        ),
        
        // 易生 eSUN - 添加渐变色测试数据
        Brand(
            name: "易生 eSUN",
            materialTypes: [
                MaterialType(
                    name: "PLA丝绸", // 假设这是您想要的材料类型名称
                    colors: [
                        ColorProperties(name: "红-绿-蓝"), // 三色渐变
                        ColorProperties(name: "红-蓝"),   // 双色渐变
                        ColorProperties(name: "Rainbow") // 彩虹色
                    ]
                )
                // 如果易生还有其他材料类型，可以在这里继续添加
            ]
        ),
        
        // 这里可以添加更多品牌...
        // 例如：Polymaker等
    ]
} 