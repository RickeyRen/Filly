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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索栏
                TextField("搜索颜色", text: $searchText)
                    .padding()
                    .background(SystemColorCompatibility.tertiarySystemBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // 最近使用的颜色
                if !isAddingNew {
                    VStack(alignment: .leading) {
                        Text("最近使用")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
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
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                        .frame(height: 110)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 2)
                }
                
                if isAddingNew {
                    // 添加新颜色的视图
                    VStack(spacing: 16) {
                        TextField("颜色名称", text: $newColorName)
                            .padding()
                            .background(SystemColorCompatibility.tertiarySystemBackground)
                            .cornerRadius(10)
                        
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
                                ColorGridItem(
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
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let index = filteredColors.firstIndex(where: { $0.id == colorItem.id }) {
                                            colorLibrary.deleteColor(at: IndexSet(integer: index))
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
            .navigationTitle("选择颜色")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isAddingNew ? "返回列表" : "添加颜色") {
                        if isAddingNew {
                            isAddingNew = false
                        } else {
                            isAddingNew = true
                            newColorName = ""
                            newColor = Color.blue
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
                    Button(isAddingNew ? "返回列表" : "添加颜色") {
                        if isAddingNew {
                            isAddingNew = false
                        } else {
                            isAddingNew = true
                            newColorName = ""
                            newColor = Color.blue
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
        
        let newFilamentColor = FilamentColor(name: trimmedName, color: newColor)
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