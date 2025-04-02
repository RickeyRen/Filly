import SwiftUI

// 创建一个遵循Identifiable协议的UUID包装结构体
struct IdentifiableUUID: Identifiable {
    let id: UUID
}

struct ColorLibraryManageView: View {
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var isAddingNew = false
    @State private var selectedColorID: IdentifiableUUID? = nil
    @State private var showingConfirmation = false
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
                
                // 统计信息
                HStack {
                    VStack(alignment: .leading) {
                        Text("共 \(filteredColors.count) 种颜色")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if !colorLibrary.selectedBrand.isEmpty {
                            Text("品牌: \(colorLibrary.selectedBrand)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(SystemColorCompatibility.tertiarySystemBackground)
                
                // 颜色列表
                List {
                    if isAddingNew {
                        ColorEditorView(
                            colorLibrary: colorLibrary,
                            isNew: true,
                            isPresented: $isAddingNew,
                            editingColor: nil
                        )
                    }
                    
                    ForEach(filteredColors) { colorItem in
                        ColorLibraryItemView(color: colorItem)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedColorID = IdentifiableUUID(id: colorItem.id)
                            }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let colorToDelete = filteredColors[index]
                            colorLibrary.deleteColor(id: colorToDelete.id)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("颜色库管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            isAddingNew = true
                        }) {
                            Image(systemName: "plus")
                        }
                        
                        Menu {
                            Button(action: {
                                colorLibrary.resetToDefaults()
                            }) {
                                Label("重置为默认颜色", systemImage: "arrow.clockwise")
                            }
                            
                            Button(action: {
                                colorLibrary.addAllColorsForBrand("天瑞 Tinmorry")
                            }) {
                                Label("添加天瑞所有颜色", systemImage: "plus.circle")
                            }
                            
                            Button(role: .destructive, action: {
                                showingConfirmation = true
                            }) {
                                Label("清空颜色库", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedColorID) { identifiableID in
                if let color = colorLibrary.colors.first(where: { $0.id == identifiableID.id }) {
                    ColorEditorView(
                        colorLibrary: colorLibrary,
                        isNew: false,
                        isPresented: Binding(
                            get: { selectedColorID != nil },
                            set: { if !$0 { selectedColorID = nil } }
                        ),
                        editingColor: color
                    )
                }
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("确认清空"),
                    message: Text("确定要清空颜色库吗？此操作不可撤销。"),
                    primaryButton: .destructive(Text("清空")) {
                        colorLibrary.colors = []
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
    }
    
    private var filteredColors: [FilamentColor] {
        colorLibrary.searchColors(query: searchText)
    }
}

// 颜色库中的单个颜色项视图
struct ColorLibraryItemView: View {
    let color: FilamentColor
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                MiniFilamentReelView(color: color.getUIColor())
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                            .frame(width: 46, height: 46)
                    )
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(color.name)
                    .font(.system(size: 16, weight: .medium))
                
                HStack {
                    if !color.brand.isEmpty {
                        Text(color.brand)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if !color.brand.isEmpty && !color.materialType.isEmpty {
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if !color.materialType.isEmpty {
                        Text(color.materialType)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// 颜色编辑器视图
struct ColorEditorView: View {
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    let isNew: Bool
    @Binding var isPresented: Bool
    let editingColor: FilamentColor?
    
    @State private var colorName: String = ""
    @State private var pickedColor: Color = .blue
    @State private var brand: String = ""
    @State private var materialType: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(colorLibrary: ColorLibraryViewModel, isNew: Bool, isPresented: Binding<Bool>, editingColor: FilamentColor?) {
        self.colorLibrary = colorLibrary
        self.isNew = isNew
        self._isPresented = isPresented
        self.editingColor = editingColor
        
        if let color = editingColor {
            self._colorName = State(initialValue: color.name)
            self._pickedColor = State(initialValue: color.getUIColor())
            self._brand = State(initialValue: color.brand)
            self._materialType = State(initialValue: color.materialType)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 20) {
                // 颜色预览
                ZStack {
                    MiniFilamentReelView(color: pickedColor)
                        .frame(width: 80, height: 80)
                }
                .frame(height: 100)
                .padding(.top, 20)
                
                // 颜色名称
                TextField("颜色名称", text: $colorName)
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(SystemColorCompatibility.tertiarySystemBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // 品牌选择
                HStack {
                    Text("品牌")
                        .font(.headline)
                        .frame(width: 80, alignment: .leading)
                    
                    Picker("选择品牌", selection: $brand) {
                        Text("无").tag("")
                        ForEach(colorLibrary.availableBrands, id: \.self) { brand in
                            Text(brand).tag(brand)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("添加新品牌", text: $brand)
                        .padding(.horizontal)
                        .frame(height: 36)
                        .background(SystemColorCompatibility.secondarySystemBackground)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // 材料类型选择
                HStack {
                    Text("材料类型")
                        .font(.headline)
                        .frame(width: 80, alignment: .leading)
                    
                    Picker("选择材料类型", selection: $materialType) {
                        Text("无").tag("")
                        ForEach(colorLibrary.availableMaterialTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("添加新类型", text: $materialType)
                        .padding(.horizontal)
                        .frame(height: 36)
                        .background(SystemColorCompatibility.secondarySystemBackground)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // 颜色选择器
                SwiftUI.ColorPicker("选择颜色", selection: $pickedColor)
                    .padding()
            }
            .padding(.bottom, 20)
            
            // 按钮
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("取消")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    saveColor()
                }) {
                    Text(isNew ? "添加" : "保存")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(colorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
        }
        .navigationTitle(isNew ? "添加新颜色" : "编辑颜色")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("提示"),
                message: Text(alertMessage),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    private func saveColor() {
        let trimmedName = colorName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            alertMessage = "颜色名称不能为空"
            showingAlert = true
            return
        }
        
        if isNew {
            // 创建新颜色
            let newColor = FilamentColor(
                name: trimmedName,
                color: pickedColor,
                brand: brand,
                materialType: materialType
            )
            colorLibrary.addColor(newColor)
        } else if let originalColor = editingColor {
            // 更新现有颜色
            let updatedColor = FilamentColor(
                id: originalColor.id,
                name: trimmedName,
                colorData: ColorData(from: pickedColor),
                lastUsed: originalColor.lastUsed,
                brand: brand,
                materialType: materialType
            )
            
            if let index = colorLibrary.colors.firstIndex(where: { $0.id == originalColor.id }) {
                colorLibrary.colors[index] = updatedColor
                colorLibrary.saveColors()
            }
        }
        
        isPresented = false
    }
}

// SwiftUI预览
struct ColorLibraryManageView_Previews: PreviewProvider {
    static var previews: some View {
        ColorLibraryManageView(colorLibrary: ColorLibraryViewModel())
    }
} 