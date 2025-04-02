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
                            HStack(spacing: 8) {
                                Button(action: {
                                    colorLibrary.selectedBrand = ""
                                }) {
                                    Text("全部")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(colorLibrary.selectedBrand.isEmpty ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(colorLibrary.selectedBrand.isEmpty ? .white : .primary)
                                        .cornerRadius(16)
                                }
                                
                                ForEach(colorLibrary.availableBrands, id: \.self) { brand in
                                    Button(action: {
                                        colorLibrary.selectedBrand = brand
                                    }) {
                                        Text(brand)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(colorLibrary.selectedBrand == brand ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(colorLibrary.selectedBrand == brand ? .white : .primary)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 材料筛选器
                    if showMaterialFilter {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    colorLibrary.selectedMaterialType = ""
                                }) {
                                    Text("全部")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(colorLibrary.selectedMaterialType.isEmpty ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(colorLibrary.selectedMaterialType.isEmpty ? .white : .primary)
                                        .cornerRadius(16)
                                }
                                
                                ForEach(colorLibrary.availableMaterialTypes, id: \.self) { material in
                                    Button(action: {
                                        colorLibrary.selectedMaterialType = material
                                    }) {
                                        Text(material)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(colorLibrary.selectedMaterialType == material ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(colorLibrary.selectedMaterialType == material ? .white : .primary)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
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
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(SystemColorCompatibility.tertiarySystemBackground)
                }
                
                // 最近使用的颜色 - 使用LazyHStack提高性能
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        Text("最近使用:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                        
                        ForEach(colorLibrary.recentlyUsedColors()) { colorItem in
                            VStack(spacing: 2) {
                                MiniFilamentReelView(color: colorItem.getUIColor())
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColorName == colorItem.name ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                
                                Text(colorItem.name)
                                    .font(.system(size: 9))
                                    .lineLimit(1)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 60, height: 60)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedColorName = colorItem.name
                                self.selectedColor = colorItem.getUIColor()
                                colorLibrary.updateLastUsed(for: colorItem)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 70)
                .background(Color.black)
                
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
                    // 优化颜色网格
                    ScrollView {
                        if filteredColors.isEmpty {
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
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)
                                ],
                                spacing: 16
                            ) {
                                ForEach(filteredColors) { colorItem in
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
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                        }
                    }
                    .onAppear {
                        // 预先计算布局，减少滚动时的计算量
                        let _ = filteredColors.count
                    }
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
        }
    }
    
    private var filteredColors: [FilamentColor] {
        colorLibrary.searchColors(query: searchText)
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

// 优化的颜色网格项，提高渲染性能
struct OptimizedColorGridItem: View {
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
                    MiniFilamentReelView(color: color.getUIColor())
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