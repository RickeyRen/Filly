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
                            HStack(spacing: 16) {
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
                        }
                        .frame(height: 100)
                    }
                    .padding(.vertical, 8)
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
                    // 所有颜色列表
                    List {
                        ForEach(filteredColors) { colorItem in
                            HStack {
                                // 使用MiniFilamentReelView替换简单圆形
                                MiniFilamentReelView(color: colorItem.getUIColor())
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            .frame(width: 36, height: 36)
                                    )
                                
                                Text(colorItem.name)
                                    .padding(.leading, 8)
                                
                                Spacer()
                                
                                if selectedColorName == colorItem.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedColorName = colorItem.name
                                self.selectedColor = colorItem.getUIColor()
                                colorLibrary.updateLastUsed(for: colorItem)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .onDelete { offsets in
                            colorLibrary.deleteColor(at: offsets)
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
        VStack(spacing: 8) {
            // 使用MiniFilamentReelView替换原来的圆形
            MiniFilamentReelView(color: color)
                .frame(width: 50, height: 50)
                // 选中状态边框
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        .frame(width: 55, height: 55)
                )
            
            Text(name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 70)
                .multilineTextAlignment(.center)
        }
        .frame(width: 70)
        .padding(.vertical, 4)
    }
} 