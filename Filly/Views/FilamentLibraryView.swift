import SwiftUI
import SwiftData

struct FilamentLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel // Use the new ViewModel
    @EnvironmentObject var filamentViewModel: FilamentViewModel // For adding to user inventory
    @EnvironmentObject var colorLibrary: ColorLibraryViewModel // Access legacy color library if needed

    @State private var searchText = ""
    @State private var selectedBrand: SwiftDataBrand? = nil
    @State private var selectedMaterialType: SwiftDataMaterialType? = nil
    @State private var showingAddFilamentSheet = false
    @State private var colorToAdd: SwiftDataFilamentColor? = nil

    // Query to fetch all brands, sorted by name
    @Query(sort: \SwiftDataBrand.name) private var brands: [SwiftDataBrand]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                LibrarySearchBar(text: $searchText, placeholder: "搜索品牌、类型或颜色...")
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // Brand and Material Type Filters (only show if not searching)
                if searchText.isEmpty {
                    FilterScrollView(
                        brands: brands,
                        selectedBrand: $selectedBrand,
                        selectedMaterialType: $selectedMaterialType,
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
                            onSelectColor: { color in
                                colorToAdd = color
                                showingAddFilamentSheet = true
                            },
                            context: modelContext
                        )
                    } else if let brand = selectedBrand, let materialType = selectedMaterialType {
                        // Show colors for selected MaterialType
                        ColorGridView(
                            materialType: materialType,
                            viewModel: filamentLibraryViewModel,
                            onSelectColor: { color in
                                colorToAdd = color
                                showingAddFilamentSheet = true
                            },
                            context: modelContext
                        )
                    } else if let brand = selectedBrand {
                        // Show MaterialTypes for selected Brand
                        MaterialTypeListView(
                            brand: brand,
                            selectedMaterialType: $selectedMaterialType,
                            viewModel: filamentLibraryViewModel,
                            context: modelContext
                        )
                    } else {
                        // Show all Brands
                        BrandListView(brands: brands, selectedBrand: $selectedBrand)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("耗材库")
            .toolbar {
                // Add toolbar items if needed (e.g., add custom brand/type)
            }
            .sheet(isPresented: $showingAddFilamentSheet) {
                // Sheet to add the selected library color to user's filament list
                if let color = colorToAdd {
                    AddLegacyFilamentSheet(
                        libraryColor: color,
                        filamentViewModel: filamentViewModel,
                        colorLibrary: colorLibrary // Pass legacy color library
                    )
                }
            }
            .onAppear {
                // Ensure preset data is loaded when the view appears
                filamentLibraryViewModel.initializePresetDataIfNeeded(context: modelContext)
            }
        }
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
    @Binding var selectedBrand: SwiftDataBrand?
    @Binding var selectedMaterialType: SwiftDataMaterialType?
    let viewModel: FilamentLibraryViewModel
    let context: ModelContext

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Clear Filter Button
                if selectedBrand != nil || selectedMaterialType != nil {
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
                            if selectedBrand?.id == brand.id {
                                selectedBrand = nil
                                selectedMaterialType = nil
                            } else {
                                selectedBrand = brand
                                selectedMaterialType = nil // Reset material type when brand changes
                            }
                        }
                    }
                    .buttonStyle(FilterChipStyle(isSelected: selectedBrand?.id == brand.id, color: .blue))
                }

                // Material Type Buttons (Show only if a brand is selected)
                if let brand = selectedBrand {
                    let materialTypes = viewModel.fetchMaterialTypes(for: brand, context: context)
                    ForEach(materialTypes) { type in
                        Button(type.name) {
                            withAnimation {
                                if selectedMaterialType?.id == type.id {
                                    selectedMaterialType = nil
                                } else {
                                    selectedMaterialType = type
                                }
                            }
                        }
                        .buttonStyle(FilterChipStyle(isSelected: selectedMaterialType?.id == type.id, color: .green))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func clearFilters() {
        withAnimation {
            selectedBrand = nil
            selectedMaterialType = nil
        }
    }
}

struct BrandListView: View {
    let brands: [SwiftDataBrand]
    @Binding var selectedBrand: SwiftDataBrand?

    var body: some View {
        List {
            ForEach(brands) { brand in
                Button {
                    withAnimation { selectedBrand = brand }
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
    @Binding var selectedMaterialType: SwiftDataMaterialType?
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
                        withAnimation { selectedMaterialType = type }
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
    let onSelectColor: (SwiftDataFilamentColor) -> Void
    let context: ModelContext

    private let columns = [GridItem(.adaptive(minimum: 150))]

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
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(colors) { color in
                        ColorCard(color: color)
                            .onTapGesture {
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
    let onSelectColor: (SwiftDataFilamentColor) -> Void
    let context: ModelContext
    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        let results = viewModel.searchLibrary(query: searchText, context: context)
        ScrollView {
            if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(results) { color in
                        ColorCard(color: color)
                            .onTapGesture {
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

    var body: some View {
        VStack(alignment: .leading) {
            MiniFilamentReelView(color: color.colorData.toColor())
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                

            VStack(alignment: .leading, spacing: 2) {
                Text(color.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(color.materialType?.brand?.name ?? "N/A") - \(color.materialType?.name ?? "N/A")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                     if color.isTransparent {
                        TagView(text: "透明", color: .cyan)
                    }
                    if color.isMetallic {
                         TagView(text: "金属", color: .orange)
                    }
                     if !color.hasSpool {
                         TagView(text: "无盘", color: .gray)
                    }
                    // Add more tags if needed
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

// Sheet View to Add Legacy Filament from Library Color
struct AddLegacyFilamentSheet: View {
    @Environment(\.dismiss) var dismiss
    let libraryColor: SwiftDataFilamentColor
    @ObservedObject var filamentViewModel: FilamentViewModel // User inventory VM
    @ObservedObject var colorLibrary: ColorLibraryViewModel // Legacy color library

    // State for the new legacy filament details
    @State private var weight: Double = 1000.0
    @State private var selectedDiameter: FilamentDiameter = .mm175
    @State private var notes: String = ""
    @State private var spoolCount: Int = 1
    @State private var spoolsData: [FilamentSpool] = [FilamentSpool()] // Use FilamentSpool

    var body: some View {
        NavigationView {
            Form {
                Section("选中的耗材库颜色") {
                    HStack {
                        MiniFilamentReelView(color: libraryColor.colorData.toColor())
                            .frame(width: 30, height: 30)
                        Text(libraryColor.name)
                    }
                    Text("品牌: \(libraryColor.materialType?.brand?.name ?? "未知")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("类型: \(libraryColor.materialType?.name ?? "未知")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("添加到我的耗材") {
                     Stepper("重量: \(Int(weight))g", value: $weight, in: 100...10000, step: 100)

                    Picker("直径", selection: $selectedDiameter) {
                        ForEach(FilamentDiameter.allCases) { Text($0.description).tag($0) }
                    }

                    // Spool Count and Details Editor
                    Stepper("料盘数量: \(spoolCount)", value: $spoolCount, in: 1...10)
                        .onChange(of: spoolCount) { _, newValue in updateSpoolsData(newCount: newValue) }

                    ForEach(0..<spoolsData.count, id: \.self) { index in
                         SpoolEditorRow(index: index + 1, spool: $spoolsData[index])
                    }
                    
                    TextField("备注 (可选)", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("添加到我的耗材")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("添加") { addFilamentToInventory() } }
            }
        }
    }

    // Updates the spoolsData array based on the stepper count
    private func updateSpoolsData(newCount: Int) {
        if newCount > spoolsData.count {
            let needed = newCount - spoolsData.count
            spoolsData.append(contentsOf: (0..<needed).map { _ in FilamentSpool() }) // Use FilamentSpool
        } else if newCount < spoolsData.count {
            spoolsData.removeLast(spoolsData.count - newCount)
        }
    }

    // Adds the filament to the user's inventory (Uses original non-legacy types)
    private func addFilamentToInventory() {
        guard let materialTypeName = libraryColor.materialType?.name, 
              let inventoryType = FilamentType(rawValue: materialTypeName) else { // Use FilamentType
            print("错误：无法将库材料类型映射到 FilamentType")
            // TODO: Show alert to user?
            return
        }
        
        let brandName = libraryColor.materialType?.brand?.name ?? "未知品牌"
        let baseColorName = libraryColor.baseColorName // Use base name without spool info
        
        // Find or create original color data
        var inventoryColorData: ColorData? // Use ColorData
        if let existingInventoryColor = colorLibrary.colors.first(where: { $0.name == baseColorName && $0.brand == brandName && $0.materialType == materialTypeName }) {
            inventoryColorData = existingInventoryColor.colorData
             colorLibrary.updateLastUsed(for: existingInventoryColor)
        } else {
            // Create new original color if not found
            inventoryColorData = ColorData(from: libraryColor.colorData.toColor()) // Use ColorData
            let newInventoryColor = FilamentColor( // Use FilamentColor
                name: baseColorName, // Use base name
                color: libraryColor.colorData.toColor(),
                brand: brandName,
                materialType: materialTypeName
            )
            colorLibrary.addColor(newInventoryColor) // Add to original color library
        }
        
        let newInventoryFilament = Filament( // Use Filament
            brand: brandName,
            type: inventoryType, // Use mapped inventoryType
            color: baseColorName, // Use base name for display
            colorData: inventoryColorData, // Use inventoryColorData
            weight: weight,
            diameter: selectedDiameter,
            spools: spoolsData, // Use the edited spool data (already FilamentSpool)
            notes: notes
        )
        
        filamentViewModel.addFilament(newInventoryFilament)
        dismiss()
    }
}

// Helper Row for editing spool details in the sheet
struct SpoolEditorRow: View {
    let index: Int
    @Binding var spool: FilamentSpool // Use FilamentSpool

    var body: some View {
        VStack(alignment: .leading) {
            Text("料盘 \(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text("剩余: \(Int(spool.remainingPercentage))%")
                Slider(value: $spool.remainingPercentage, in: 0...100, step: 1)
            }
            TextField("料盘备注 (可选)", text: $spool.notes)
                .font(.footnote)
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