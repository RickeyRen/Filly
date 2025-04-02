import SwiftUI

struct EditFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Binding var filament: Filament
    @Environment(\.presentationMode) var presentationMode
    
    @State private var brand: String
    @State private var customBrand = ""
    @State private var selectedType: String
    @State private var color: String
    @State private var selectedColor: Color
    @State private var weight: Double
    @State private var selectedDiameter: FilamentDiameter
    @State private var notes: String
    @State private var showingCustomBrand = false
    @State private var showingColorPicker = false
    
    init(viewModel: FilamentViewModel, colorLibrary: ColorLibraryViewModel, filament: Binding<Filament>) {
        self.viewModel = viewModel
        self.colorLibrary = colorLibrary
        self._filament = filament
        
        let unwrappedFilament = filament.wrappedValue
        
        _brand = State(initialValue: unwrappedFilament.brand)
        _selectedType = State(initialValue: unwrappedFilament.type)
        _color = State(initialValue: unwrappedFilament.color)
        _selectedColor = State(initialValue: unwrappedFilament.getColor())
        _weight = State(initialValue: unwrappedFilament.weight)
        _selectedDiameter = State(initialValue: unwrappedFilament.diameter)
        _notes = State(initialValue: unwrappedFilament.notes)
    }
    
    // 获取品牌可用的材料类型
    private func getAvailableMaterialTypes(for brand: String) -> [String] {
        if brand.isEmpty {
            // 如果没有选择品牌，返回默认的所有类型
            return ["PLA", "ABS", "PETG", "TPU", "PC", "ASA", "PVA", "HIPS", "尼龙", "其他"]
        }
        
        // 从颜色库中获取该品牌的材料类型
        let types = colorLibrary.colors
            .filter { $0.brand == brand }
            .map { $0.materialType }
        
        let uniqueTypes = Array(Set(types)).filter { !$0.isEmpty }.sorted()
        
        // 如果没有找到该品牌的任何材料类型，返回默认的所有类型
        return uniqueTypes.isEmpty ? ["PLA", "ABS", "PETG", "TPU", "PC", "ASA", "PVA", "HIPS", "尼龙", "其他"] : uniqueTypes
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    if showingCustomBrand {
                        TextField("输入品牌名称", text: $customBrand)
                            .onChange(of: customBrand) { oldValue, newValue in
                                brand = newValue
                            }
                        
                        Button("选择预设品牌") {
                            showingCustomBrand = false
                            brand = PresetBrands.brands.first ?? ""
                        }
                    } else {
                        Picker("品牌", selection: $brand) {
                            ForEach(PresetBrands.brands, id: \.self) { brand in
                                Text(brand).tag(brand)
                            }
                        }
                        
                        Button("添加自定义品牌") {
                            showingCustomBrand = true
                            customBrand = brand
                        }
                    }
                    
                    // 使用let绑定计算一次材料类型，避免重复计算
                    let availableTypes = getAvailableMaterialTypes(for: brand)
                    Picker("类型", selection: $selectedType) {
                        // 根据选择的品牌动态显示材料类型
                        ForEach(availableTypes, id: \.self) { typeString in
                            Text(typeString).tag(typeString)
                        }
                    }
                    .onChange(of: brand) { oldValue, newValue in
                        // 当品牌变化时，检查当前选择的类型是否在新品牌的可用类型中
                        let types = getAvailableMaterialTypes(for: newValue)
                        if !types.isEmpty && !types.contains(selectedType) {
                            // 如果不在，则选择该品牌的第一个可用类型
                            if let firstType = types.first {
                                selectedType = firstType
                            }
                        }
                    }
                    
                    Button(action: {
                        showingColorPicker = true
                        // 在此处设置筛选条件为当前选择的品牌和材料类型
                        colorLibrary.selectedBrand = brand
                        colorLibrary.selectedMaterialType = selectedType
                    }) {
                        HStack {
                            Text("颜色")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !color.isEmpty {
                                MiniFilamentReelView(color: selectedColor)
                                    .frame(width: 30, height: 30)
                                
                                Text(color)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("选择颜色")
                                    .foregroundColor(.secondary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("规格")) {
                    Picker("直径", selection: $selectedDiameter) {
                        ForEach(FilamentDiameter.allCases) { diameter in
                            Text(diameter.description).tag(diameter)
                        }
                    }
                    
                    Stepper(value: $weight, in: 100...10000, step: 100) {
                        HStack {
                            Text("重量")
                            Spacer()
                            Text("\(Int(weight))g")
                        }
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("提示")) {
                    Text("耗材盘管理请在详情页面进行")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("编辑耗材")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(brand.isEmpty || color.isEmpty)
                }
                #elseif os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(brand.isEmpty || color.isEmpty)
                }
                #endif
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(
                    colorLibrary: colorLibrary,
                    selectedColorName: $color, 
                    selectedColor: $selectedColor
                )
            }
        }
    }
    
    private func saveChanges() {
        // 获取颜色数据
        var colorData: ColorData? = nil
        if let colorItem = colorLibrary.colors.first(where: { $0.name == color }) {
            colorData = colorItem.colorData
            colorLibrary.updateLastUsed(for: colorItem)
        } else if !color.isEmpty {
            colorData = ColorData(from: selectedColor)
            let newColor = FilamentColor(name: color, color: selectedColor)
            colorLibrary.addColor(newColor)
        }
        
        var updatedFilament = filament
        updatedFilament.brand = brand
        updatedFilament.type = selectedType
        updatedFilament.color = color
        updatedFilament.colorData = colorData
        updatedFilament.weight = weight
        updatedFilament.diameter = selectedDiameter
        updatedFilament.notes = notes
        
        viewModel.updateFilament(updatedFilament)
        filament = updatedFilament
        presentationMode.wrappedValue.dismiss()
    }
} 