import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ColorPickerView: View {
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Binding var selectedColorName: String
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var isAddingNew = false
    @State private var newColorName = ""
    @State private var newColor = Color.blue
    @State private var newBrand = ""
    @State private var newMaterialType = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showBrandFilter = false
    @State private var showMaterialFilter = false
    
    // 缓存过滤后的颜色结果，避免滚动时频繁计算
    @State private var cachedFilteredColors: [FilamentColor] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏和筛选器区域
                VStack(spacing: 0) {
                    // 搜索栏和筛选按钮
                    HStack(spacing: 10) {
                        TextField("搜索颜色", text: $searchText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                            .onChange(of: searchText) { _ in
                                updateFilteredColors()
                            }
                        
                        Button(action: {
                            showBrandFilter.toggle()
                            if showBrandFilter {
                                showMaterialFilter = false // 避免同时展开两个筛选器
                            }
                        }) {
                            Label("品牌", systemImage: "tag")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(colorLibrary.selectedBrand.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showMaterialFilter.toggle()
                            if showMaterialFilter {
                                showBrandFilter = false // 避免同时展开两个筛选器
                            }
                        }) {
                            Label("材料", systemImage: "square.stack.3d.up")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(colorLibrary.selectedMaterialType.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // 品牌筛选器
                    if showBrandFilter {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 6) {
                                Button(action: {
                                    colorLibrary.selectedBrand = ""
                                    updateFilteredColors()
                                }) {
                                    Text("全部")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(colorLibrary.selectedBrand.isEmpty ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(colorLibrary.selectedBrand.isEmpty ? .white : .primary)
                                        .cornerRadius(12)
                                        .font(.system(size: 13))
                                }
                                
                                ForEach(colorLibrary.availableBrands, id: \.self) { brand in
                                    Button(action: {
                                        colorLibrary.selectedBrand = brand
                                        updateFilteredColors()
                                    }) {
                                        Text(brand)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(colorLibrary.selectedBrand == brand ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(colorLibrary.selectedBrand == brand ? .white : .primary)
                                            .cornerRadius(12)
                                            .font(.system(size: 13))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 32)
                        .padding(.vertical, 4)
                    }
                    
                    // 材料筛选器
                    if showMaterialFilter {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 6) {
                                Button(action: {
                                    colorLibrary.selectedMaterialType = ""
                                    updateFilteredColors()
                                }) {
                                    Text("全部")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(colorLibrary.selectedMaterialType.isEmpty ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(colorLibrary.selectedMaterialType.isEmpty ? .white : .primary)
                                        .cornerRadius(12)
                                        .font(.system(size: 13))
                                }
                                
                                ForEach(colorLibrary.availableMaterialTypes, id: \.self) { material in
                                    Button(action: {
                                        colorLibrary.selectedMaterialType = material
                                        updateFilteredColors()
                                    }) {
                                        Text(material)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(colorLibrary.selectedMaterialType == material ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(colorLibrary.selectedMaterialType == material ? .white : .primary)
                                            .cornerRadius(12)
                                            .font(.system(size: 13))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 32)
                        .padding(.vertical, 4)
                    }
                }
                .background(SystemColorCompatibility.secondarySystemBackground)
                
                // 选中的筛选条件指示器
                if !colorLibrary.selectedBrand.isEmpty || !colorLibrary.selectedMaterialType.isEmpty {
                    HStack {
                        if !colorLibrary.selectedBrand.isEmpty {
                            Text("品牌: \(colorLibrary.selectedBrand)")
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        
                        if !colorLibrary.selectedMaterialType.isEmpty {
                            Text("材料: \(colorLibrary.selectedMaterialType)")
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        Button("清除") {
                            colorLibrary.selectedBrand = ""
                            colorLibrary.selectedMaterialType = ""
                            updateFilteredColors()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(SystemColorCompatibility.tertiarySystemBackground)
                }
                
                // 添加新颜色的视图或颜色网格
                if isAddingNew {
                    // 添加新颜色的视图
                    VStack(spacing: 16) {
                        TextField("颜色名称", text: $newColorName)
                            .padding()
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                        
                        HStack {
                            Picker("品牌", selection: $newBrand) {
                                Text("(空)").tag("")
                                ForEach(colorLibrary.availableBrands, id: \.self) { brand in
                                    Text(brand).tag(brand)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                            
                            TextField("新品牌", text: $newBrand)
                                .padding()
                                .background(SystemColorCompatibility.tertiarySystemBackground)
                                .cornerRadius(10)
                                .disabled(!newBrand.isEmpty)
                        }
                        
                        HStack {
                            Picker("材料类型", selection: $newMaterialType) {
                                Text("(空)").tag("")
                                ForEach(colorLibrary.availableMaterialTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                            
                            TextField("新材料类型", text: $newMaterialType)
                                .padding()
                                .background(SystemColorCompatibility.tertiarySystemBackground)
                                .cornerRadius(10)
                                .disabled(!newMaterialType.isEmpty)
                        }
                        
                        SwiftUI.ColorPicker("选择颜色", selection: $newColor)
                            .padding()
                        
                        HStack {
                            Button(action: {
                                isAddingNew = false
                            }) {
                                Text("取消")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                saveNewColor()
                            }) {
                                Text("保存")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(newColorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding()
                } else {
                    // 优化颜色网格 - 使用缓存的过滤结果
                    ScrollView {
                        if cachedFilteredColors.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("没有找到匹配的颜色")
                                    .foregroundColor(.gray)
                                
                                if !colorLibrary.selectedBrand.isEmpty || !colorLibrary.selectedMaterialType.isEmpty {
                                    Button("清除筛选条件") {
                                        colorLibrary.selectedBrand = ""
                                        colorLibrary.selectedMaterialType = ""
                                        updateFilteredColors()
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // 使用ID确保列表重建时能够正确识别每个项
                            VStack(spacing: 0) {
                                LazyVGrid(
                                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                                    spacing: 16
                                ) {
                                    ForEach(cachedFilteredColors) { colorItem in
                                        OptimizedColorGridItem(
                                            color: colorItem,
                                            isSelected: selectedColorName == colorItem.name,
                                            onTap: {
                                                self.selectedColorName = colorItem.name
                                                self.selectedColor = colorItem.getUIColor()
                                                colorLibrary.updateLastUsed(for: colorItem)
                                                presentationMode.wrappedValue.dismiss()
                                            }
                                        )
                                        .id(colorItem.id) // 确保每个项有唯一标识符
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    // 禁用默认的滚动指示器以提高性能
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("选择颜色")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !isAddingNew {
                            Menu {
                                Button(action: {
                                    colorLibrary.resetToDefaults()
                                }) {
                                    Label("重置为默认颜色", systemImage: "arrow.clockwise")
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    colorLibrary.addAllColorsForBrand("天瑞 Tinmorry")
                                }) {
                                    Label("添加天瑞所有颜色", systemImage: "plus.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        
                        Button(isAddingNew ? "返回列表" : "添加颜色") {
                            if isAddingNew {
                                isAddingNew = false
                            } else {
                                isAddingNew = true
                                newColorName = ""
                                newColor = Color.blue
                                newBrand = ""
                                newMaterialType = ""
                            }
                        }
                    }
                }
                #elseif os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    HStack {
                        if !isAddingNew {
                            Menu {
                                Button(action: {
                                    colorLibrary.resetToDefaults()
                                }) {
                                    Label("重置为默认颜色", systemImage: "arrow.clockwise")
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    colorLibrary.addAllColorsForBrand("天瑞 Tinmorry")
                                }) {
                                    Label("添加天瑞所有颜色", systemImage: "plus.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        
                        Button(isAddingNew ? "返回列表" : "添加颜色") {
                            if isAddingNew {
                                isAddingNew = false
                            } else {
                                isAddingNew = true
                                newColorName = ""
                                newColor = Color.blue
                                newBrand = ""
                                newMaterialType = ""
                            }
                        }
                    }
                }
                #endif
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .onAppear {
                // 首次加载时初始化过滤颜色缓存
                updateFilteredColors()
            }
            .onChange(of: colorLibrary.colors) { _ in
                // 当颜色列表发生变化时更新缓存
                updateFilteredColors()
            }
            .onChange(of: colorLibrary.selectedBrand) { _ in
                // 当品牌筛选条件变化时更新缓存
                updateFilteredColors()
            }
            .onChange(of: colorLibrary.selectedMaterialType) { _ in
                // 当材料筛选条件变化时更新缓存
                updateFilteredColors()
            }
        }
    }
    
    // 更新筛选后的颜色缓存
    private func updateFilteredColors() {
        cachedFilteredColors = colorLibrary.searchColors(query: searchText)
    }
    
    private func saveNewColor() {
        let trimmedName = newColorName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            alertMessage = "颜色名称不能为空"
            showingAlert = true
            return
        }
        
        let newFilamentColor = FilamentColor(
            name: trimmedName, 
            color: newColor,
            brand: newBrand,
            materialType: newMaterialType
        )
        colorLibrary.addColor(newFilamentColor)
        
        // 更新选中的颜色
        selectedColorName = trimmedName
        selectedColor = newColor
        
        // 重置状态
        isAddingNew = false
        newColorName = ""
        
        // 显示提示
        alertMessage = "颜色已保存"
        showingAlert = true
    }
}

// 优化的颜色网格项，实现Equatable以提高SwiftUI Diff性能
struct OptimizedColorGridItem: View, Equatable {
    let color: FilamentColor
    let isSelected: Bool
    let onTap: () -> Void
    
    // 使用equatable提高diff性能
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.color.id == rhs.color.id && lhs.isSelected == rhs.isSelected
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // 颜色圆环
            VStack(spacing: 4) {
                // 使用预渲染的静态内容提高性能
                ZStack {
                    // 在颜色选择页面使用静态版本，不使用动画
                    StaticFilamentReelView(color: color.getUIColor())
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 0.5)
                                .frame(width: 52, height: 52)
                        )
                }
                .frame(width: 54, height: 54)
                .clipShape(Circle())
                
                // 简化文本层级
                Text(color.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .frame(width: 70)
            }
            
            // 品牌信息，使用条件渲染减少复杂度
            if !color.brand.isEmpty || !color.materialType.isEmpty {
                Text(color.brand.replacingOccurrences(of: " Tinmorry", with: ""))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
        .frame(height: 85)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// 完全静态的耗材盘模型 - 仅用于颜色选择界面
struct StaticFilamentReelView: View {
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    private let cachedColors: SimpleFillamentReel2D.CachedColors
    
    init(color: Color) {
        self.color = color
        self.cachedColors = SimpleFillamentReel2D.CachedColors(baseColor: color)
    }
    
    var body: some View {
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
            
            // 使用较少的同心圆减少渲染负担 - 固定位置不旋转
            StaticCircleWindings(colorScheme: colorScheme, contrastColors: cachedColors.contrastColors)
            
            // 添加两个标记点，完全静态
            ForEach(0..<2) { i in
                let angle = Double(i) * 180.0 + 30.0
                let radius = 20.0
                
                // 小圆点标记
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘
            Circle()
                .stroke(cachedColors.centerContrastColor, lineWidth: 1.5)
                .frame(width: 18, height: 18)
            
            // 简化的中心孔 - 完全静态
            StaticCenterHole()
            
            // 顶部高光 - 固定位置
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: -20))
                .offset(y: -6)
                .blur(radius: 3.0)
                
            // 最外侧边框
            Circle()
                .stroke(cachedColors.borderColor, lineWidth: 1.0)
                .frame(width: 50, height: 50)
        }
    }
}

// 静态同心圆组件
private struct StaticCircleWindings: View {
    let colorScheme: ColorScheme
    let contrastColors: [Color]
    
    var body: some View {
        // 减少圆圈数量以提高性能
        ForEach(0..<3) { i in
            let radius = 14.0 + CGFloat(i) * 4.5
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
                .rotationEffect(Angle(degrees: rotationOffset))
        }
    }
}

// 静态中心孔组件
private struct StaticCenterHole: View {
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
            
            // 三段圆环 - 固定位置
            ForEach(0..<3) { i in
                let startAngle = Double(i) * 120 + 20
                let endAngle = startAngle + 80
                
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360)
                    .stroke(
                        Color.black.opacity(0.8),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 12, height: 12)
                    .rotationEffect(Angle(degrees: -90))
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.4)
    }
}

// 更新ColorBubble视图，提高重用效率
struct ColorBubble: View {
    let color: Color
    let name: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            // 简化渲染层级
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2.5 : 0.8)
                    )
            }
            .frame(width: 46, height: 46)
            
            Text(name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
        .frame(width: 60, height: 90)
    }
} 