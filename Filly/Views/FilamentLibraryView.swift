import SwiftUI
import SwiftData

// MARK: - Identifiable Item for Sheet
struct FilamentSheetItem: Identifiable {
    let id: UUID // Use the color's UUID for Identifiable conformance
    let libraryColorName: String // Full name like "白色 (含料盘)"
    let libraryColorBaseName: String // Base name like "白色"
    let libraryColorCode: String?
    let libraryColorHasSpool: Bool
    let brandName: String
    let materialTypeName: String
    let swiftUIColor: Color
    // Keep the original ID if needed for saving logic later
    let originalColorID: UUID 
}

// MARK: - Main View
struct FilamentLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    @EnvironmentObject var filamentViewModel: FilamentViewModel

    @State private var searchText = ""
    // 保存 ID 而不是对象引用
    @State private var selectedBrandId: UUID? = nil
    @State private var selectedMaterialTypeId: UUID? = nil
    
    // Use identifiable item for the sheet state
    @State private var sheetItem: FilamentSheetItem? = nil 

    @Query(sort: \SwiftDataBrand.name) private var brands: [SwiftDataBrand]
    
    // 通过 ID 安全获取对象的计算属性
    private var selectedBrand: SwiftDataBrand? {
        guard let id = selectedBrandId else { return nil }
        return brands.first { $0.id == id }
    }
    
    private var selectedMaterialType: SwiftDataMaterialType? {
        guard let id = selectedMaterialTypeId, let brand = selectedBrand else { return nil }
        return brand.materialTypes.first { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                LibrarySearchBar(text: $searchText, placeholder: "搜索品牌、类型或颜色...")
                    .padding(.horizontal).padding(.vertical, 8)

                // Filters
                if searchText.isEmpty {
                    FilterScrollView(
                        brands: brands,
                        selectedBrandId: $selectedBrandId,
                        selectedMaterialTypeId: $selectedMaterialTypeId,
                        viewModel: filamentLibraryViewModel,
                        context: modelContext
                    )
                    .padding(.bottom, 8)
                }

                // Content Area
                Group {
                    if !searchText.isEmpty {
                        SearchResultsView(
                            searchText: searchText,
                            viewModel: filamentLibraryViewModel,
                            // Pass the closure to handle selection
                            onSelectColor: { color in handleColorSelection(color) }, 
                            context: modelContext
                        )
                    } else if let brand = selectedBrand, let materialType = selectedMaterialType {
                        ColorGridView(
                            materialTypeId: materialType.id,
                            viewModel: filamentLibraryViewModel,
                            // Pass the closure to handle selection
                            onSelectColor: { color in handleColorSelection(color) }, 
                            context: modelContext
                        )
                    } else if let brand = selectedBrand {
                        MaterialTypeListView(
                            brandId: brand.id,
                            selectedMaterialTypeId: $selectedMaterialTypeId,
                            viewModel: filamentLibraryViewModel,
                            context: modelContext
                        )
                    } else {
                        BrandListView(brands: brands, selectedBrandId: $selectedBrandId)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("耗材库")
            .toolbar {
                // Add toolbar items if needed (e.g., add custom brand/type)
            }
            // Use .sheet(item: ...) modifier
            .sheet(item: $sheetItem) { item in 
                // Pass the prepared item to the sheet
                AddLegacyFilamentSheet(
                    item: item, // Pass the whole item struct
                    filamentViewModel: filamentViewModel
                )
            }
            .onAppear {
                filamentLibraryViewModel.initializePresetDataIfNeeded(context: modelContext)
            }
            // 添加通知监听，当主题改变时清除选择状态，避免访问无效对象
            .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { _ in
                // 清除选择状态
                selectedBrandId = nil
                selectedMaterialTypeId = nil
            }
        }
    }
    
    // Function to handle color selection and prepare sheet item
    private func handleColorSelection(_ color: SwiftDataFilamentColor) {
        // 安全提取数据，避免在创建 item 后又访问已销毁的对象
        let brandName = color.materialType?.brand?.name ?? "未知品牌"
        let materialTypeName = color.materialType?.name ?? "未知类型"
        let colorName = color.name
        let baseColorName = color.baseColorName
        let colorCode = color.code
        let hasSpool = color.hasSpool
        let colorValue = color.colorData.toColor()
        let colorId = color.id
        
        // 使用提取的数据创建 item
        self.sheetItem = FilamentSheetItem(
            id: colorId,
            libraryColorName: colorName,
            libraryColorBaseName: baseColorName,
            libraryColorCode: colorCode,
            libraryColorHasSpool: hasSpool,
            brandName: brandName,
            materialTypeName: materialTypeName,
            swiftUIColor: colorValue,
            originalColorID: colorId
        )
    }
}

// MARK: - Subviews

struct LibrarySearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct FilterScrollView: View {
    let brands: [SwiftDataBrand]
    @Binding var selectedBrandId: UUID?
    @Binding var selectedMaterialTypeId: UUID?
    let viewModel: FilamentLibraryViewModel
    let context: ModelContext

    // 临时存储当前选中的品牌，避免嵌套获取导致的性能问题
    private var selectedBrand: SwiftDataBrand? {
        guard let id = selectedBrandId else { return nil }
        return brands.first { $0.id == id }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Clear Filter Button
                if selectedBrandId != nil || selectedMaterialTypeId != nil {
                    Button(action: clearFilters) {
                        Label("清除", systemImage: "xmark")
                            .font(.caption)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.red.opacity(0.15)).foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }

                // Brand Buttons
                ForEach(brands) { brand in
                    Button(brand.name) {
                        withAnimation {
                            if selectedBrandId == brand.id {
                                selectedBrandId = nil
                                selectedMaterialTypeId = nil
                            } else {
                                selectedBrandId = brand.id
                                selectedMaterialTypeId = nil // Reset material type when brand changes
                            }
                        }
                    }
                    .buttonStyle(FilterChipStyle(isSelected: selectedBrandId == brand.id, color: .blue))
                }

                // Material Type Buttons (Show only if a brand is selected)
                if let brand = selectedBrand {
                    let materialTypes = viewModel.fetchMaterialTypes(for: brand, context: context)
                    ForEach(materialTypes) { type in
                        Button(type.name) {
                            withAnimation {
                                if selectedMaterialTypeId == type.id {
                                    selectedMaterialTypeId = nil
                                } else {
                                    selectedMaterialTypeId = type.id
                                }
                            }
                        }
                        .buttonStyle(FilterChipStyle(isSelected: selectedMaterialTypeId == type.id, color: .green))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func clearFilters() {
        withAnimation {
            selectedBrandId = nil
            selectedMaterialTypeId = nil
        }
    }
}

struct BrandListView: View {
    let brands: [SwiftDataBrand]
    @Binding var selectedBrandId: UUID?
    @State private var showingAddBrandSheet = false
    @State private var newBrandName = ""
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    
    var body: some View {
        List {
            // 添加新品牌的按钮
            Section {
                Button {
                    showingAddBrandSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("添加新品牌")
                    }
                }
            }
            
            Section {
                if brands.isEmpty {
                    Text("未找到品牌信息")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(brands) { brand in
                        Button {
                            withAnimation { selectedBrandId = brand.id }
                        } label: {
                            HStack {
                                Text(brand.name)
                                Spacer()
                                Text("\(brand.materialTypes.count) 种材料")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                filamentLibraryViewModel.deleteBrand(brand, context: modelContext)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("耗材品牌")
        .alert("添加新品牌", isPresented: $showingAddBrandSheet) {
            TextField("品牌名称", text: $newBrandName)
            Button("取消", role: .cancel) {
                newBrandName = ""
            }
            Button("添加") {
                if !newBrandName.isEmpty {
                    filamentLibraryViewModel.addBrand(name: newBrandName, context: modelContext)
                    newBrandName = ""
                }
            }
        } message: {
            Text("请输入新品牌的名称")
        }
    }
}

struct MaterialTypeListView: View {
    // 改为使用ID而非直接对象引用
    let brandId: UUID
    @Binding var selectedMaterialTypeId: UUID?
    let viewModel: FilamentLibraryViewModel
    let context: ModelContext
    
    // 新增状态变量
    @State private var showingAddTypeSheet = false
    @State private var newTypeName = ""
    
    // 使用Query获取品牌对象
    @Query private var brands: [SwiftDataBrand]
    
    // 通过ID安全获取品牌
    private var brand: SwiftDataBrand? {
        brands.first { $0.id == brandId }
    }
    
    init(brandId: UUID, selectedMaterialTypeId: Binding<UUID?>, viewModel: FilamentLibraryViewModel, context: ModelContext) {
        self.brandId = brandId
        self._selectedMaterialTypeId = selectedMaterialTypeId
        self.viewModel = viewModel
        self.context = context
        
        // 配置Query以获取所有品牌
        let descriptor = FetchDescriptor<SwiftDataBrand>()
        self._brands = Query(descriptor)
    }

    var body: some View {
        List {
            if let brand = brand {
                let materialTypes = viewModel.fetchMaterialTypes(for: brand, context: context)
                
                // 添加新类型的按钮
                Section {
                    Button {
                        showingAddTypeSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("添加新材料类型")
                        }
                    }
                }
                
                Section {
                    if materialTypes.isEmpty {
                        Text("未找到 \(brand.name) 的材料类型。")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(materialTypes) { type in
                            Button {
                                withAnimation { selectedMaterialTypeId = type.id }
                            } label: {
                                HStack {
                                    Text(type.name)
                                    Spacer()
                                    Text("\(type.colors.count) 种颜色")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                 .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let type = materialTypes.first(where: { $0.id == type.id }) {
                                        viewModel.deleteMaterialType(type, context: context)
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            } else {
                Text("无法加载品牌信息")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(brand?.name ?? "材料类型") // 安全获取品牌名称
        .alert("添加新材料类型", isPresented: $showingAddTypeSheet) {
            TextField("材料类型名称", text: $newTypeName)
            Button("取消", role: .cancel) {
                newTypeName = ""
            }
            Button("添加") {
                if !newTypeName.isEmpty, let brand = brand {
                    viewModel.addMaterialType(name: newTypeName, to: brand, context: context)
                    newTypeName = ""
                }
            }
        } message: {
            Text("请输入新材料类型的名称")
        }
    }
}

struct ColorGridView: View {
    // 改为使用ID而非直接对象引用
    let materialTypeId: UUID
    let viewModel: FilamentLibraryViewModel
    let onSelectColor: (SwiftDataFilamentColor) -> Void 
    let context: ModelContext
    
    // 新增状态变量
    @State private var showingAddColorSheet = false
    @State private var newColorName = ""
    @State private var selectedColor = Color.blue
    @State private var isTransparent = false
    @State private var isMetallic = false
    @State private var hasSpool = true
    @State private var colorCode = ""
    
    // 使用Query获取材料类型
    @Query private var materialTypes: [SwiftDataMaterialType]
    
    // 通过ID安全获取材料类型
    private var materialType: SwiftDataMaterialType? {
        materialTypes.first { $0.id == materialTypeId }
    }
    
    // 定义列布局
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 3)
    private let gridSpacing: CGFloat = 12
    
    init(materialTypeId: UUID, viewModel: FilamentLibraryViewModel, onSelectColor: @escaping (SwiftDataFilamentColor) -> Void, context: ModelContext) {
        self.materialTypeId = materialTypeId
        self.viewModel = viewModel
        self.onSelectColor = onSelectColor
        self.context = context
        
        // 配置Query以获取所有材料类型
        let descriptor = FetchDescriptor<SwiftDataMaterialType>()
        self._materialTypes = Query(descriptor)
    }

    var body: some View {
        ScrollView {
            if let materialType = materialType {
                // 添加新颜色按钮
                Button {
                    showingAddColorSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("添加新颜色")
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top)
                
                let colors = viewModel.fetchColors(for: materialType, context: context)
                if colors.isEmpty {
                    ContentUnavailableView(
                        "无颜色",
                        systemImage: "paintpalette",
                        description: Text("\(materialType.name)下没有颜色信息。")
                    )
                    .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        ForEach(colors) { color in
                            ColorCard(color: color)
                                .onTapGesture {
                                    onSelectColor(color)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        context.delete(color)
                                        try? context.save()
                                    } label: {
                                        Label("删除颜色", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "无法加载材料类型",
                    systemImage: "exclamationmark.triangle",
                    description: Text("请返回上一级重新选择")
                )
                .padding()
            }
        }
        .navigationTitle(materialType?.name ?? "颜色") // 安全获取材料类型名称
        .sheet(isPresented: $showingAddColorSheet) {
            if let materialType = materialType {
                NavigationView {
                    Form {
                        Section(header: Text("基本信息")) {
                            TextField("颜色名称", text: $newColorName)
                            TextField("型号代码 (可选)", text: $colorCode)
                            ColorPicker("选择颜色", selection: $selectedColor)
                        }
                        
                        Section(header: Text("属性")) {
                            Toggle("是否透明", isOn: $isTransparent)
                            Toggle("是否金属质感", isOn: $isMetallic)
                            Toggle("是否包含料盘", isOn: $hasSpool)
                        }
                        
                        Section {
                            Button("添加") {
                                addNewColor(to: materialType)
                                showingAddColorSheet = false
                            }
                            .frame(maxWidth: .infinity)
                            .disabled(newColorName.isEmpty)
                        }
                    }
                    .navigationTitle("添加新颜色")
                    .navigationBarItems(trailing: Button("取消") {
                        showingAddColorSheet = false
                    })
                }
            }
        }
    }
    
    private func addNewColor(to materialType: SwiftDataMaterialType) {
        // 创建颜色数据
        #if os(iOS)
        let uiColor = UIColor(selectedColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        let nsColor = NSColor(selectedColor)
        var r: CGFloat = 0.5
        var g: CGFloat = 0.5
        var b: CGFloat = 0.5
        var a: CGFloat = 1.0
        if let rgbColor = nsColor.usingColorSpace(.sRGB) {
            rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        }
        #endif
        
        // 直接使用ColorPicker提供的颜色创建colorData
        let colorData = SwiftDataColorData(from: selectedColor)
        
        // 打印颜色值，用于调试
        print("添加新颜色: \(newColorName), RGB: \(colorData.red), \(colorData.green), \(colorData.blue)")
        
        // 全名格式设置
        let fullName = hasSpool ? 
            "\(newColorName) (含料盘)" : 
            "\(newColorName) (无料盘)"
        
        // 添加新颜色
        viewModel.addColor(
            name: fullName, 
            colorData: colorData, 
            to: materialType, 
            context: context,
            code: colorCode.isEmpty ? nil : colorCode,
            isTransparent: isTransparent,
            isMetallic: isMetallic,
            hasSpool: hasSpool
        )
        
        // 重置表单
        newColorName = ""
        colorCode = ""
        selectedColor = .blue
        isTransparent = false
        isMetallic = false
        hasSpool = true
    }
}

struct SearchResultsView: View {
    let searchText: String
    let viewModel: FilamentLibraryViewModel
     // This closure now simply passes the selected color back
    let onSelectColor: (SwiftDataFilamentColor) -> Void
    let context: ModelContext
    // Apply the same 3-column layout to search results
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 3)
    private let gridSpacing: CGFloat = 12

    var body: some View {
        let results = viewModel.searchLibrary(query: searchText, context: context)
        ScrollView {
            if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                LazyVGrid(columns: columns, spacing: gridSpacing) {
                    ForEach(results) { color in
                        ColorCard(color: color)
                            .onTapGesture {
                                // Directly call the passed closure
                                onSelectColor(color)
                            }
                    }
                }
                .padding()
            }
        }
    }
}

struct ColorCard: View {
    let color: SwiftDataFilamentColor
    private let textContentMinHeight: CGFloat = 70

    // 计算渐变色数组
    private var gradientColors: [Color] {
        let lowercasedName = color.baseColorName.lowercased() // 使用 baseColorName 并转为小写
        // 特殊处理彩虹色 - 改为包含判断
        if lowercasedName.contains("rainbow") || lowercasedName.contains("彩虹") {
            return [
                .red, .orange, .yellow, .green, .blue, .indigo, .purple
            ]
        }
        
        // 尝试解析以'-'分隔的颜色字符串 (使用 color.name 或 color.baseColorName)
        // 如果 name 包含 (含料盘) 等后缀，分割 baseColorName 可能更准确
        let colorComponents = color.baseColorName.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // 如果只有一个组件或无法解析，则返回来自ColorData的颜色
        if colorComponents.count <= 1 {
            return [color.colorData.toColor()]
        }
        
        // 尝试将每个组件解析为颜色
        let colors: [Color] = colorComponents.compactMap { component in
            // 优先尝试解析十六进制颜色
            if component.starts(with: "#"), let uiColor = UIColor(hexString: component) {
                return Color(uiColor)
            } else {
                // 否则，尝试使用默认颜色映射 (需要能访问到getDefaultColor)
                // 为了简化，这里我们直接返回一个默认颜色或尝试从 ColorData 获取
                // 注意：更健壮的方案是在 SwiftDataFilamentColor 或其ViewModel中实现颜色解析
                return getDefaultColorFallback(for: component) ?? color.colorData.toColor()
            }
        }
        
        // 如果成功解析出多种颜色，则返回颜色数组，否则返回单一颜色
        return colors.count > 1 ? colors : [color.colorData.toColor()]
    }
    
    // 简化的颜色名称到Color的映射（备用）
    private func getDefaultColorFallback(for name: String) -> Color? {
        let lowerName = name.lowercased()
        switch lowerName {
            case "red", "红": return .red
            case "green", "绿": return .green
            case "blue", "蓝": return .blue
            case "yellow", "黄": return .yellow
            case "orange", "橙": return .orange
            case "purple", "紫": return .purple
            case "indigo", "靛": return .indigo
            case "pink", "粉": return .pink
            case "cyan", "青": return .cyan
            case "black", "黑": return .black
            case "white", "白": return .white
            case "gray", "灰": return .gray
            case "silver", "银": return Color(red: 192/255, green: 192/255, blue: 192/255)
            case "gold", "金": return Color(red: 255/255, green: 215/255, blue: 0/255)
            default: return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reel Image part - 使用计算出的渐变色数组
            MiniFilamentReelView(colors: gradientColors) 
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 8)

            // Text and Tag content area
            VStack(alignment: .leading, spacing: 4) {
                Text("\(color.baseColorName) \(color.code ?? "")")
                    .font(.headline)
                    .lineLimit(2)
                    .frame(minHeight: UIFont.preferredFont(forTextStyle: .headline).lineHeight * 1.9, alignment: .top)

                Text("\(color.materialType?.brand?.name ?? "N/A") - \(color.materialType?.name ?? "N/A")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Tag Area
                HStack(spacing: 4) {
                     if color.isTransparent {
                        TagView(text: "透明", color: .cyan)
                    }
                    if color.isMetallic {
                         TagView(text: "金属", color: .orange)
                    }
                     if !color.hasSpool {
                         TagView(text: "无料盘", color: .gray)
                    }
                    Spacer()
                }
                .frame(height: 20)
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: textContentMinHeight)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

// MARK: - Update AddLegacyFilamentSheet to accept Item

struct AddLegacyFilamentSheet: View {
    @Environment(\.dismiss) var dismiss
    // Accept the prepared Item struct instead of the full SwiftData object
    let item: FilamentSheetItem 
    @ObservedObject var filamentViewModel: FilamentViewModel
    
    // State remains the same
    @State private var weight: Double = 1000.0
    @State private var selectedDiameter: FilamentDiameter = .mm175
    @State private var notes: String = ""
    @State private var spoolCount: Int = 1
    @State private var spoolsData: [FilamentSpool] = [FilamentSpool()]
    // 添加错误处理的状态变量
    @State private var showingAddError = false
    @State private var addErrorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section 1: Use data from the item
                    VStack(alignment: .leading, spacing: 12) {
                        Text("选中的耗材库颜色").font(.caption).foregroundStyle(.secondary).padding(.bottom, 4)
                        HStack(spacing: 15) {
                            MiniFilamentReelView(color: item.swiftUIColor) // Use color from item
                                .frame(width: 50, height: 50).scaleEffect(0.7)
                                .background(Color(.systemGray6)).clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(item.libraryColorName) // Use name from item
                                    .font(.headline)
                                Text("品牌: \(item.brandName)") // Use brand from item
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text("类型: \(item.materialTypeName)") // Use type from item
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    
                    // Section 2: Add to My Filaments Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("添加到我的耗材")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)

                        HStack {
                            Text("重量")
                            Spacer()
                            Text("\(Int(weight))g")
                                .foregroundStyle(.secondary)
                            Stepper("", value: $weight, in: 100...10000, step: 100).labelsHidden()
                        }

                        HStack {
                             Text("直径")
                             Spacer()
                             Picker("直径", selection: $selectedDiameter) {
                                 ForEach(FilamentDiameter.allCases) { Text($0.description).tag($0) }
                             }
                             .pickerStyle(.menu)
                             .labelsHidden()
                             .tint(.secondary) // Style the picker arrow
                         }

                        HStack {
                            Text("料盘数量")
                            Spacer()
                            Text("\(spoolCount)")
                                .foregroundStyle(.secondary)
                            Stepper("", value: $spoolCount, in: 1...10)
                                .labelsHidden()
                                .onChange(of: spoolCount) { _, newValue in updateSpoolsData(newCount: newValue) }
                        }
                        
                        Divider()
                        
                        // Spool Editor Rows within the card
                        ForEach(0..<spoolsData.count, id: \.self) { index in
                             SpoolEditorRowRedesigned(index: index + 1, spool: $spoolsData[index])
                             if index < spoolsData.count - 1 {
                                 Divider().padding(.vertical, 5)
                             }
                        }
                        
                        Divider().padding(.bottom, 5)
                        
                        Text("备注 (可选)")
                             .font(.subheadline)
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
                            .font(.body)
                            .padding(.bottom, 5)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                }
                .padding() // Padding around the VStack containing the cards
            }
            .background(Color(.systemGroupedBackground)) // Use grouped background for the ScrollView
            .navigationTitle("添加到我的耗材")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                     Button("添加") { addFilamentToInventory() }
                     // Add validation if needed, e.g., disable if weight is 0?
                }
            }
            // 添加错误提示的 alert
            .alert("添加失败", isPresented: $showingAddError) {
                Button("好的") { }
            } message: {
                Text(addErrorMessage)
            }
        }
    }
    
    // updateSpoolsData remains the same
    private func updateSpoolsData(newCount: Int) {
        if newCount > spoolsData.count {
            let needed = newCount - spoolsData.count
            spoolsData.append(contentsOf: (0..<needed).map { _ in FilamentSpool() }) // Use FilamentSpool
        } else if newCount < spoolsData.count {
            spoolsData.removeLast(spoolsData.count - newCount)
        }
    }

    // 更新addFilamentToInventory方法不再使用FilamentTypeViewModel
    private func addFilamentToInventory() {
        // 直接使用filamentViewModel创建或查找材料类型
        let materialType = filamentViewModel.findOrCreateType(name: item.materialTypeName)
        
        // 创建Filament对象并添加到库存
        let newFilament = Filament(
            brand: item.brandName,
            type: materialType,
            color: item.libraryColorBaseName,
            colorData: ColorData(from: item.swiftUIColor),
            weight: weight,
            diameter: selectedDiameter,
            spools: spoolsData,
            notes: notes
        )
        
        // 添加到库存
        filamentViewModel.addFilament(newFilament)
        
        // 关闭sheet并重置状态
        dismiss()
    }
}

// MARK: - Redesigned SpoolEditorRow

struct SpoolEditorRowRedesigned: View {
    let index: Int
    @Binding var spool: FilamentSpool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("料盘 \(index)")
                .font(.subheadline)
                .fontWeight(.medium)
                
            HStack {
                Text("剩余: \(Int(spool.remainingPercentage))%")
                    .font(.callout)
                Slider(value: $spool.remainingPercentage, in: 0...100, step: 1)
            }
            
            TextField("料盘 \(index) 备注 (可选)", text: $spool.notes)
                .font(.callout)
                .foregroundStyle(.secondary)
                .textFieldStyle(.plain) // Use plain style for less visual clutter
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                 .padding(.leading, -4) // Minor adjustment to align with slider
        }
    }
}

// MARK: - Helper Views & Styles

struct FilterChipStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? color : color.opacity(0.15))
            .foregroundColor(isSelected ? .white : color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TagView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

// MARK: - Preview
#Preview {
    // Create in-memory container for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SwiftDataBrand.self, configurations: config)
    
    // Add sample data for preview
    let sampleVM = FilamentLibraryViewModel()
    Task { @MainActor in
        sampleVM.initializePresetDataIfNeeded(context: container.mainContext)
    }

    return FilamentLibraryView()
        .modelContainer(container)
        .environmentObject(sampleVM)
         // Provide dummy ViewModels for preview
        .environmentObject(FilamentViewModel())
} 