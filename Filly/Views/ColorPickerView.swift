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
                // 搜索栏和筛选器
                VStack(spacing: 8) {
                    HStack {
                        TextField("搜索颜色", text: $searchText)
                            .padding()
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                        
                        Button(action: {
                            showBrandFilter.toggle()
                        }) {
                            Label("品牌", systemImage: "tag")
                                .padding(8)
                                .background(colorLibrary.selectedBrand.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showMaterialFilter.toggle()
                        }) {
                            Label("材料", systemImage: "square.stack.3d.up")
                                .padding(8)
                                .background(colorLibrary.selectedMaterialType.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
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
                        .padding(.bottom, 8)
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
                        .padding(.bottom, 8)
                    }
                }
                .padding(.top, 8)
                .background(SystemColorCompatibility.secondarySystemBackground)
                
                // 最近使用的颜色
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        Text("最近使用:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                        
                        ForEach(colorLibrary.recentlyUsedColors()) { colorItem in
                            ColorBubble(
                                color: colorItem.getUIColor(),
                                name: colorItem.name,
                                isSelected: selectedColorName == colorItem.name
                            )
                            .onTapGesture {
                                self.selectedColorName = colorItem.name
                                self.selectedColor = colorItem.getUIColor()
                                colorLibrary.updateLastUsed(for: colorItem)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .background(SystemColorCompatibility.tertiarySystemBackground)
                
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
                    // 所有颜色 - 网格布局替代列表
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
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 0),
                                    GridItem(.flexible(), spacing: 0),
                                    GridItem(.flexible(), spacing: 0),
                                    GridItem(.flexible(), spacing: 0),
                                    GridItem(.flexible(), spacing: 0)
                                ],
                                spacing: 5
                            ) {
                                ForEach(filteredColors) { colorItem in
                                    VStack {
                                        ColorGridItem(
                                            color: colorItem.getUIColor(),
                                            name: colorItem.name,
                                            isSelected: selectedColorName == colorItem.name
                                        )
                                        
                                        if !colorItem.brand.isEmpty || !colorItem.materialType.isEmpty {
                                            HStack(spacing: 4) {
                                                if !colorItem.brand.isEmpty {
                                                    Text(colorItem.brand)
                                                        .font(.system(size: 7))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                if !colorItem.brand.isEmpty && !colorItem.materialType.isEmpty {
                                                    Text("·")
                                                        .font(.system(size: 7))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                if !colorItem.materialType.isEmpty {
                                                    Text(colorItem.materialType)
                                                        .font(.system(size: 7))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .lineLimit(1)
                                        }
                                    }
                                    .onTapGesture {
                                        self.selectedColorName = colorItem.name
                                        self.selectedColor = colorItem.getUIColor()
                                        colorLibrary.updateLastUsed(for: colorItem)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    .contextMenu {
                                        Button {
                                            if let index = filteredColors.firstIndex(where: { $0.id == colorItem.id }) {
                                                colorLibrary.deleteColor(id: colorItem.id)
                                            }
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 20)
                        }
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

struct ColorBubble: View {
    let color: Color
    let name: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            // 图标容器，固定尺寸并裁剪溢出部分
            ZStack {
                MiniFilamentReelView(color: color)
                    .frame(width: 42, height: 42)
                    // 选中状态边框
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2.5 : 0.8)
                            .frame(width: 44, height: 44)
                    )
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())
            
            // 文本放在图标下方，清晰分开
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

// 添加网格布局项组件
struct ColorGridItem: View {
    let color: Color
    let name: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            // 图标容器，固定尺寸并裁剪溢出部分
            ZStack {
                MiniFilamentReelView(color: color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 0.5)
                            .frame(width: 42, height: 42)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            // 文本放在图标下方，避免重叠
            HStack(spacing: 1) {
                Text(name)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.system(size: 6, weight: .bold))
                }
            }
            .padding(.top, 1)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 68)
        .contentShape(Rectangle())
        .padding(.horizontal, 2)
    }
} 