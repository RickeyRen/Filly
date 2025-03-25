import SwiftUI

struct AddFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var brand = ""
    @State private var customBrand = ""
    @State private var selectedType = FilamentType.pla
    @State private var color = ""
    @State private var weight = 1000.0
    @State private var selectedDiameter = FilamentDiameter.mm175
    @State private var notes = ""
    @State private var showingCustomBrand = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    if showingCustomBrand {
                        TextField("输入品牌名称", text: $customBrand)
                            .onChange(of: customBrand) { _ in
                                brand = customBrand
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
                            customBrand = ""
                            brand = ""
                        }
                    }
                    
                    Picker("类型", selection: $selectedType) {
                        ForEach(FilamentType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("颜色", text: $color)
                        .autocapitalization(.none)
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
            }
            .navigationTitle("添加耗材")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveFilament()
                    }
                    .disabled(brand.isEmpty || color.isEmpty)
                }
            }
        }
        .onAppear {
            // 设置默认选中的品牌
            if !PresetBrands.brands.isEmpty {
                brand = PresetBrands.brands.first!
            }
        }
    }
    
    private func saveFilament() {
        let newFilament = Filament(
            brand: brand,
            type: selectedType,
            color: color,
            weight: weight,
            diameter: selectedDiameter,
            remainingPercentage: 100,
            notes: notes
        )
        
        viewModel.addFilament(newFilament)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @Binding var filament: Filament
    @Environment(\.presentationMode) var presentationMode
    
    @State private var brand: String
    @State private var customBrand = ""
    @State private var selectedType: FilamentType
    @State private var color: String
    @State private var weight: Double
    @State private var selectedDiameter: FilamentDiameter
    @State private var remainingPercentage: Double
    @State private var notes: String
    @State private var showingCustomBrand = false
    
    init(viewModel: FilamentViewModel, filament: Binding<Filament>) {
        self.viewModel = viewModel
        self._filament = filament
        
        // 初始化状态变量
        _brand = State(initialValue: filament.wrappedValue.brand)
        _selectedType = State(initialValue: filament.wrappedValue.type)
        _color = State(initialValue: filament.wrappedValue.color)
        _weight = State(initialValue: filament.wrappedValue.weight)
        _selectedDiameter = State(initialValue: filament.wrappedValue.diameter)
        _remainingPercentage = State(initialValue: filament.wrappedValue.remainingPercentage)
        _notes = State(initialValue: filament.wrappedValue.notes)
        
        // 检查是否是自定义品牌
        _showingCustomBrand = State(initialValue: !PresetBrands.brands.contains(filament.wrappedValue.brand))
        if !PresetBrands.brands.contains(filament.wrappedValue.brand) {
            _customBrand = State(initialValue: filament.wrappedValue.brand)
        } else {
            _customBrand = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    if showingCustomBrand {
                        TextField("输入品牌名称", text: $customBrand)
                            .onChange(of: customBrand) { _ in
                                brand = customBrand
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
                    
                    Picker("类型", selection: $selectedType) {
                        ForEach(FilamentType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("颜色", text: $color)
                        .autocapitalization(.none)
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
                    
                    HStack {
                        Text("剩余量")
                        Spacer()
                        Text("\(Int(remainingPercentage))%")
                    }
                    
                    Slider(value: $remainingPercentage, in: 0...100, step: 5)
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("编辑耗材")
            .toolbar {
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
            }
        }
    }
    
    private func saveChanges() {
        var updatedFilament = filament
        updatedFilament.brand = brand
        updatedFilament.type = selectedType
        updatedFilament.color = color
        updatedFilament.weight = weight
        updatedFilament.diameter = selectedDiameter
        updatedFilament.remainingPercentage = remainingPercentage
        updatedFilament.notes = notes
        
        viewModel.updateFilament(updatedFilament)
        filament = updatedFilament
        presentationMode.wrappedValue.dismiss()
    }
} 