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
    
    // 计算筛选颜色仅在需要时执行，而不是每次重绘都计算
    private var filteredColors: [FilamentColor] {
        colorLibrary.searchColors(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索筛选部分，按需展示以减少渲染消耗
                FilterHeaderView(
                    colorLibrary: colorLibrary,
                    searchText: $searchText,
                    showBrandFilter: $showBrandFilter,
                    showMaterialFilter: $showMaterialFilter,
                    filteredCount: filteredColors.count
                )
                
                // 颜色列表 - 经过优化的性能
                List {
                    if isAddingNew {
                        ColorLibraryEditorView(
                            colorLibrary: colorLibrary,
                            isNew: true,
                            isPresented: $isAddingNew,
                            editingColor: nil
                        )
                    }
                    
                    ForEach(filteredColors) { colorItem in
                        OptimizedColorItemView(
                            color: colorItem,
                            onTap: {
                                selectedColorID = IdentifiableUUID(id: colorItem.id)
                            }
                        )
                        .id(colorItem.id) // 确保正确的标识
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
                    ColorLibraryEditorView(
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
}

// 优化的筛选视图 - 拆分为单独组件以提高性能
struct FilterHeaderView: View {
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Binding var searchText: String
    @Binding var showBrandFilter: Bool
    @Binding var showMaterialFilter: Bool
    let filteredCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏和筛选按钮
            HStack {
                TextField("搜索颜色", text: $searchText)
                    .padding()
                    .background(SystemColorCompatibility.tertiarySystemBackground)
                    .cornerRadius(10)
                
                Button(action: {
                    showBrandFilter.toggle()
                    if showBrandFilter {
                        showMaterialFilter = false // 避免同时展开两个筛选器
                    }
                }) {
                    Label("品牌", systemImage: "tag")
                        .padding(8)
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
                        .padding(8)
                        .background(colorLibrary.selectedMaterialType.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // 品牌筛选器 - 优化渲染性能
            if showBrandFilter {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
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
            
            // 材料筛选器 - 优化渲染性能
            if showMaterialFilter {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
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
            
            // 选中的筛选条件指示器和统计信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // 筛选条件指示器 - 简化渲染
                    if !colorLibrary.selectedBrand.isEmpty || !colorLibrary.selectedMaterialType.isEmpty {
                        HStack(spacing: 8) {
                            if !colorLibrary.selectedBrand.isEmpty {
                                IndicatorTag(text: colorLibrary.selectedBrand)
                            }
                            
                            if !colorLibrary.selectedMaterialType.isEmpty {
                                IndicatorTag(text: colorLibrary.selectedMaterialType)
                            }
                            
                            Button("清除") {
                                colorLibrary.selectedBrand = ""
                                colorLibrary.selectedMaterialType = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // 统计信息
                    Text("共 \(filteredCount) 种颜色")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(SystemColorCompatibility.secondarySystemBackground)
    }
}

// 优化的标签组件 - 提取重复元素减少渲染消耗
struct IndicatorTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
}

// 优化的颜色项视图，使用缓存渲染减少计算
struct OptimizedColorItemView: View {
    let color: FilamentColor
    let onTap: () -> Void
    
    // 提高渲染性能
    @State private var cachedUIColor: Color?
    
    var body: some View {
        HStack(spacing: 16) {
            // 简化图标渲染
            Circle()
                .fill(cachedUIColor ?? color.getUIColor())
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
                .onAppear {
                    // 缓存颜色值以避免重复计算
                    if cachedUIColor == nil {
                        cachedUIColor = color.getUIColor()
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(color.name)
                    .font(.system(size: 16, weight: .medium))
                
                if !color.brand.isEmpty || !color.materialType.isEmpty {
                    Text(color.brand + ((!color.brand.isEmpty && !color.materialType.isEmpty) ? " · " : "") + color.materialType)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
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
struct ColorLibraryEditorView: View {
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