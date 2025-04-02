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
                        .onChange(of: searchText) { _ in
                            updateFilteredColors()
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(SystemColorCompatibility.secondarySystemBackground)
                
                // 颜色网格
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 16) {
                        ForEach(cachedFilteredColors, id: \.id) { color in
                            ColorItemView(color: color, isSelected: selectedColorName == color.name) {
                                selectedColor = color.getUIColor()
                                selectedColorName = color.name
                                colorLibrary.updateLastUsed(for: color)
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
                    Button(action: {
                        isAddingNew = true
                    }) {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNew) {
                ColorEditorView(
                    isPresented: $isAddingNew,
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
        }
    }
    
    private var gridItems: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 80, maximum: 100), spacing: 16), count: calculateColumnsForWidth())
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
                MiniFilamentReelView(color: color.getUIColor())
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
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(color.name)
                .lineLimit(1)
                .font(.caption)
                .foregroundColor(.white)
                .frame(maxWidth: 80)
                .truncationMode(.tail)
            
            if !color.brand.isEmpty {
                Text(color.brand)
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

struct ColorEditorView: View {
    @Binding var isPresented: Bool
    @Binding var colorName: String
    @Binding var color: Color
    @Binding var brand: String
    @Binding var materialType: String
    
    var onSave: () -> Void
    
    @ObservedObject private var colorViewModel = ColorLibraryViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("颜色名称", text: $colorName)
                    .autocapitalization(.none)
                
                Picker("品牌", selection: $brand) {
                    Text("无").tag("")
                    ForEach(colorViewModel.availableBrands, id: \.self) { brand in
                        Text(brand).tag(brand)
                    }
                }
                
                if brand == "其他" {
                    TextField("输入品牌名称", text: $brand)
                        .autocapitalization(.none)
                }
                
                Picker("材料类型", selection: $materialType) {
                    Text("无").tag("")
                    ForEach(colorViewModel.availableMaterialTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                
                if materialType == "其他" {
                    TextField("输入材料类型", text: $materialType)
                        .autocapitalization(.none)
                }
                
                SwiftUI.ColorPicker("选择颜色", selection: $color)
                
                Button("保存") {
                    onSave()
                    isPresented = false
                }
                .disabled(colorName.isEmpty)
            }
            .navigationTitle("添加新颜色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// 系统颜色兼容层，用于在iOS和macOS之间统一颜色
struct SystemColorCompatibility {
    static var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    static var tertiarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.textBackgroundColor)
        #endif
    }
} 