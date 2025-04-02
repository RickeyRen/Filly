import SwiftUI
import Combine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// 导入系统颜色兼容层
// SystemColorCompatibility在其他文件中已定义

struct ColorPickerView: View {
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Binding var selectedColorName: String
    @Binding var selectedColor: FilamentColor?
    @Environment(\.presentationMode) var presentationMode
    @State private var isPresented: Bool = true
    
    // 添加onSelect回调
    var onSelect: ((FilamentColor) -> Void)?
    
    @State private var searchText = ""
    @State private var isAddingNewColor = false
    @State private var newColorName = ""
    @State private var newColor = Color.blue
    @State private var newBrand = ""
    @State private var newMaterialType = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 缓存过滤后的颜色结果，避免滚动时频繁计算
    @State private var cachedFilteredColors: [FilamentColor] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    TextField("搜索颜色", text: $searchText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(SystemColorCompatibility.tertiarySystemBackground)
                        .cornerRadius(10)
                        .onChange(of: searchText) { oldValue, newValue in
                            updateFilteredColors()
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(SystemColorCompatibility.secondarySystemBackground)
                
                // 品牌和材料类型过滤区域
                HStack {
                    Picker("品牌", selection: $colorLibrary.selectedBrand) {
                        Text("全部").tag("")
                        ForEach(colorLibrary.availableBrands, id: \.self) { brand in
                            Text(brand).tag(brand)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("材料", selection: $colorLibrary.selectedMaterialType) {
                        Text("全部").tag("")
                        ForEach(colorLibrary.availableMaterialTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(SystemColorCompatibility.secondarySystemBackground)
                
                // 颜色网格
                ScrollView {
                    // 简化复杂表达式
                    let columns = Array(repeating: GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16), count: calculateColumnsForWidth())
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cachedFilteredColors, id: \.id) { color in
                            let isSelected = selectedColor?.id == color.id
                            ColorItemView(color: color, isSelected: isSelected) {
                                selectedColor = color
                                selectedColorName = color.name
                                colorLibrary.updateLastUsed(for: color)
                                if let onSelect = onSelect {
                                    onSelect(color)
                                }
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)))
            }
            .navigationTitle("选择颜色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            colorLibrary.clearSavedColorsAndReset()
                            updateFilteredColors()
                        }) {
                            Label("重置颜色库", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(action: {
                            colorLibrary.addAllTinzhuPLABasicColors()
                            updateFilteredColors()
                        }) {
                            Label("添加拓竹所有颜色", systemImage: "paintpalette")
                        }
                        
                        Button(action: {
                            isAddingNewColor = true
                        }) {
                            Label("添加新颜色", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewColor) {
                ColorEditorView(
                    isPresented: $isAddingNewColor,
                    colorName: $newColorName,
                    color: $newColor,
                    brand: $newBrand,
                    materialType: $newMaterialType,
                    onSave: {
                        if !newColorName.isEmpty {
                            let newFilamentColor = FilamentColor(
                                name: newColorName,
                                color: newColor,
                                brand: newBrand,
                                materialType: newMaterialType
                            )
                            colorLibrary.addColor(newFilamentColor)
                            newColorName = ""
                            newColor = .blue
                            newBrand = ""
                            newMaterialType = ""
                            updateFilteredColors()
                        } else {
                            alertMessage = "请输入颜色名称"
                            showingAlert = true
                        }
                    }
                )
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
            .onAppear {
                updateFilteredColors()
            }
            .onDisappear {
                // 关闭颜色选择器时重置筛选条件
                colorLibrary.selectedBrand = ""
                colorLibrary.selectedMaterialType = ""
            }
        }
    }
    
    private func calculateColumnsForWidth() -> Int {
        // 根据屏幕宽度动态计算列数
        #if os(iOS)
        let screenWidth = UIScreen.main.bounds.width
        #else
        let screenWidth = NSScreen.main?.frame.width ?? 800
        #endif
        
        if screenWidth > 800 {
            return 6
        } else if screenWidth > 600 {
            return 5
        } else if screenWidth > 400 {
            return 4
        } else {
            return 3
        }
    }
    
    // 更新过滤后的颜色列表
    private func updateFilteredColors() {
        cachedFilteredColors = colorLibrary.searchColors(query: searchText)
    }
}

struct ColorItemView: View {
    let color: FilamentColor
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            Button(action: action) {
                MiniFilamentReelView(color: color.getUIColor(), colorName: color.name)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Circle()
                            .stroke(isHovering ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .onAppear {
                        #if DEBUG
                        print(color.debugColorInfo())
                        #endif
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(color.name)
                .lineLimit(1)
                .font(.caption)
                .foregroundColor(.white)
                .frame(maxWidth: 80)
                .truncationMode(.tail)
            
            if !color.brand.isEmpty {
                Text("\(color.brand) \(color.materialType)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .frame(maxWidth: 80)
                    .truncationMode(.tail)
            }
        }
        .frame(width: 80, height: 100)
    }
}

