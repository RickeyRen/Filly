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
    @EnvironmentObject var colorLibrary: ColorLibraryViewModel

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
                            materialType: materialType,
                            viewModel: filamentLibraryViewModel,
                            // Pass the closure to handle selection
                            onSelectColor: { color in handleColorSelection(color) }, 
                            context: modelContext
                        )
                    } else if let brand = selectedBrand {
                        MaterialTypeListView(
                            brand: brand,
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
                    filamentViewModel: filamentViewModel,
                    colorLibrary: colorLibrary
                )
            }
            .onAppear {
                filamentLibraryViewModel.initializePresetDataIfNeeded(context: modelContext)
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

    var body: some View {
        List {
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
                    .contentShape(Rectangle()) // Make entire row tappable
                }
                .buttonStyle(.plain) // Use plain button style in List
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct MaterialTypeListView: View {
    let brand: SwiftDataBrand
    @Binding var selectedMaterialTypeId: UUID?
    let viewModel: FilamentLibraryViewModel
    let context: ModelContext

    var body: some View {
        let materialTypes = viewModel.fetchMaterialTypes(for: brand, context: context)
        List {
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
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(brand.name) // Show brand name in title
    }
}

struct ColorGridView: View {
    let materialType: SwiftDataMaterialType
    let viewModel: FilamentLibraryViewModel
    // This closure now simply passes the selected color back
    let onSelectColor: (SwiftDataFilamentColor) -> Void 
    let context: ModelContext

    // Define 3 flexible columns with desired spacing
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 3)
    private let gridSpacing: CGFloat = 12

    var body: some View {
        let colors = viewModel.fetchColors(for: materialType, context: context)
        ScrollView {
            if colors.isEmpty {
                ContentUnavailableView(
                    "无颜色",
                    systemImage: "paintpalette",
                    description: Text("\(materialType.name)下没有颜色信息。")
                )
                .padding()
            } else {
                // Use the new column definition and spacing
                LazyVGrid(columns: columns, spacing: gridSpacing) {
                    ForEach(colors) { color in
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
        .navigationTitle(materialType.name)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reel Image part (remains the same)
            MiniFilamentReelView(color: color.colorData.toColor())
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
    @ObservedObject var colorLibrary: ColorLibraryViewModel

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

    // Update addFilamentToInventory to use data from the item
    private func addFilamentToInventory() {
        // 直接尝试从 item.materialTypeName 创建 FilamentType
        // 不再做特殊类型映射，因为我们已经在 FilamentType 枚举中添加了所有支持的类型
        guard let inventoryType = FilamentType(rawValue: item.materialTypeName) else {
            addErrorMessage = "无法识别的材料类型: \(item.materialTypeName)，请先在 FilamentType 枚举中添加此类型"
            showingAddError = true
            print("错误：无法将库材料类型映射到 FilamentType: \(item.materialTypeName)")
            return
        }
        
        // 创建 Filament 对象并添加到库存
        let newFilament = Filament(
            brand: item.brandName,
            type: inventoryType,
            color: item.libraryColorBaseName,
            colorData: ColorData(from: item.swiftUIColor),
            weight: weight,
            diameter: selectedDiameter,
            spools: spoolsData,
            notes: notes
        )
        
        // 添加到库存
        filamentViewModel.addFilament(newFilament)
        
        // 更新最后使用的颜色
        if let existingInventoryColor = colorLibrary.colors.first(where: {
            $0.name == item.libraryColorBaseName &&
            $0.brand == item.brandName &&
            $0.materialType == item.materialTypeName
        }) {
            colorLibrary.updateLastUsed(for: existingInventoryColor)
        } else {
            let newLegacyColor = FilamentColor(
                name: item.libraryColorBaseName,
                color: item.swiftUIColor,
                brand: item.brandName,
                materialType: item.materialTypeName
            )
            colorLibrary.addColor(newLegacyColor)
        }
        
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
        .environmentObject(ColorLibraryViewModel())
} 