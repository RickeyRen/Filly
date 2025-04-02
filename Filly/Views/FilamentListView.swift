import SwiftUI
import SwiftData

// 导入动态图标组件
// import Foundation

struct FilamentListView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddSheet = false
    
    @Query(sort: \SwiftDataBrand.name) private var brands: [SwiftDataBrand]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.filaments.isEmpty {
                    emptyView
                } else {
                    filamentsList
                }
            }
            .navigationTitle("我的耗材")
            .searchable(text: $searchText, prompt: "搜索耗材...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    SelectFromFilamentLibraryView(filamentViewModel: viewModel, 
                                              filamentLibraryViewModel: filamentLibraryViewModel)
                    .navigationTitle("从耗材库添加")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showingAddSheet = false
                            }
                        }
                    }
                }
                .onAppear {
                    // 确保耗材库已经初始化
                    filamentLibraryViewModel.initializePresetDataIfNeeded(context: modelContext)
                }
            }
        }
    }
    
    var filteredFilaments: [Filament] {
        if searchText.isEmpty {
            return viewModel.filaments
        } else {
            return viewModel.filaments.filter { filament in
                filament.brand.localizedCaseInsensitiveContains(searchText) ||
                filament.type.name.localizedCaseInsensitiveContains(searchText) ||
                filament.color.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("暂无耗材")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("点击右上角 + 按钮从耗材库添加新耗材")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("添加第一个耗材")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var filamentsList: some View {
        List {
            ForEach(filteredFilaments) { filament in
                NavigationLink(destination: FilamentDetailView(viewModel: viewModel, filament: filament)) {
                    FilamentRowView(filament: filament)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deleteFilament(id: filament.id)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// 添加从耗材库选择的辅助视图
struct SelectFromFilamentLibraryView: View {
    @ObservedObject var filamentViewModel: FilamentViewModel
    @ObservedObject var filamentLibraryViewModel: FilamentLibraryViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedBrandId: UUID? = nil
    @State private var selectedMaterialTypeId: UUID? = nil
    
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
        VStack(spacing: 0) {
            // 搜索栏
            LibrarySearchBar(text: $searchText, placeholder: "搜索品牌、类型或颜色...")
                .padding(.horizontal).padding(.vertical, 8)
            
            // 筛选栏
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
            
            // 内容区域
            Group {
                if !searchText.isEmpty {
                    SearchResultsView(
                        searchText: searchText,
                        viewModel: filamentLibraryViewModel,
                        onSelectColor: { color in addFilament(from: color) },
                        context: modelContext
                    )
                } else if let brand = selectedBrand, let materialType = selectedMaterialType {
                    ColorGridView(
                        materialTypeId: materialType.id,
                        viewModel: filamentLibraryViewModel,
                        onSelectColor: { color in addFilament(from: color) },
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
    }
    
    // 从耗材库颜色创建新耗材
    private func addFilament(from color: SwiftDataFilamentColor) {
        // 安全提取数据
        let brandName = color.materialType?.brand?.name ?? "未知品牌"
        let materialTypeName = color.materialType?.name ?? "未知类型"
        let colorName = color.baseColorName
        let colorRGB = color.colorData
        
        // 创建颜色数据
        let filamentColorData = ColorData(
            red: colorRGB.red,
            green: colorRGB.green,
            blue: colorRGB.blue,
            alpha: colorRGB.alpha
        )
        
        // 查找或创建对应的耗材类型
        let filamentType = filamentViewModel.typeViewModel.findOrCreateType(name: materialTypeName)
        
        // 创建新耗材，初始化一个新的耗材盘
        let newFilament = Filament(
            brand: brandName,
            type: filamentType,
            color: colorName,
            colorData: filamentColorData,
            weight: 1000,
            diameter: .mm175,
            spools: [FilamentSpool(remainingPercentage: 100)],
            notes: ""
        )
        
        // 添加到库存
        filamentViewModel.addFilament(newFilament)
        
        // 关闭sheet
        dismiss()
    }
}

struct FilamentRowView: View {
    let filament: Filament
    
    var body: some View {
        HStack(spacing: 15) {
            FilamentReelView(color: filament.getColor())
                .frame(width: 40, height: 40)
                .scaleEffect(0.5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(filament.brand)
                    .font(.headline)
                
                HStack {
                    Text(filament.type.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                    
                    Text(filament.color)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                    
                    Text(filament.diameter.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(filament.remainingSpoolCount)盘")
                    .fontWeight(.medium)
                
                if filament.fullSpoolCount > 0 {
                    Text("\(filament.fullSpoolCount)盘全新")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                let partialCount = filament.remainingSpoolCount - filament.fullSpoolCount
                if partialCount > 0 {
                    Text("\(partialCount)盘部分使用")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 