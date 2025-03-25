import SwiftUI

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
                    .background(Color(.systemGray6))
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
                                        color: colorItem.toColor(),
                                        name: colorItem.name,
                                        isSelected: selectedColorName == colorItem.name
                                    )
                                    .onTapGesture {
                                        self.selectedColorName = colorItem.name
                                        self.selectedColor = colorItem.toColor()
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
                            .background(Color(.systemGray6))
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
                                Circle()
                                    .fill(colorItem.toColor())
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 1)
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
                                self.selectedColor = colorItem.toColor()
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
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                // 内部深色阴影，创造凹陷感
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.7),
                                    color.opacity(1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .blur(radius: 2)
                        .offset(x: 0, y: 1)
                )
                // 高光效果
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .scaleEffect(0.85)
                )
                // 边缘高光
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                // 选中状态边框
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
                // 外部阴影
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 2)
                // 环境光阴影
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
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