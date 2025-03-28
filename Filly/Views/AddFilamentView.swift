import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct AddFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var brand = ""
    @State private var customBrand = ""
    @State private var selectedType = FilamentType.pla
    @State private var color = ""
    @State private var selectedColor = Color.blue
    @State private var weight = 1000.0
    @State private var selectedDiameter = FilamentDiameter.mm175
    @State private var notes = ""
    @State private var spoolCount = 1
    @State private var spoolsData: [FilamentSpool] = [FilamentSpool()]
    @State private var showingCustomBrand = false
    @State private var showingColorPicker = false
    
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
                    
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("颜色")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !color.isEmpty {
                                Circle()
                                    .fill(selectedColor)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
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
                
                Section(header: Text("耗材盘")) {
                    HStack {
                        Text("添加盘数")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                if spoolCount > 1 {
                                    spoolCount -= 1
                                    updateSpoolsData(newCount: spoolCount)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(spoolCount > 1 ? .blue : .gray)
                                    .font(.title2)
                            }
                            .disabled(spoolCount <= 1)
                            
                            Text("\(spoolCount)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                if spoolCount < 10 {
                                    spoolCount += 1
                                    updateSpoolsData(newCount: spoolCount)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(spoolCount < 10 ? .blue : .gray)
                                    .font(.title2)
                            }
                            .disabled(spoolCount >= 10)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    ForEach(0..<spoolsData.count, id: \.self) { index in
                        SpoolEditorView(
                            index: index + 1,
                            spool: $spoolsData[index]
                        )
                        .padding(.vertical, 8)
                        
                        if index < spoolsData.count - 1 {
                            Divider()
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
                #if os(iOS)
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
                #elseif os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveFilament()
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
        .onAppear {
            // 设置默认选中的品牌
            if !PresetBrands.brands.isEmpty {
                brand = PresetBrands.brands.first!
            }
            
            // 设置默认颜色
            if let firstColor = colorLibrary.colors.first {
                color = firstColor.name
                selectedColor = firstColor.getUIColor()
            }
            
            // 初始化耗材盘数据
            updateSpoolsData(newCount: spoolCount)
        }
    }
    
    private func updateSpoolsData(newCount: Int) {
        // 保持现有数据
        if newCount > spoolsData.count {
            // 添加新盘
            let newSpools = (0..<(newCount - spoolsData.count)).map { _ in FilamentSpool() }
            spoolsData.append(contentsOf: newSpools)
        } else if newCount < spoolsData.count {
            // 移除多余的盘
            spoolsData = Array(spoolsData.prefix(newCount))
        }
    }
    
    private func saveFilament() {
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
        
        let newFilament = Filament(
            brand: brand,
            type: selectedType,
            color: color,
            colorData: colorData,
            weight: weight,
            diameter: selectedDiameter,
            spools: spoolsData,
            notes: notes
        )
        
        viewModel.addFilament(newFilament)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Binding var filament: Filament
    @Environment(\.presentationMode) var presentationMode
    
    @State private var brand: String
    @State private var customBrand = ""
    @State private var selectedType: FilamentType
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
        
        // 初始化状态变量
        _brand = State(initialValue: filament.wrappedValue.brand)
        _selectedType = State(initialValue: filament.wrappedValue.type)
        _color = State(initialValue: filament.wrappedValue.color)
        _selectedColor = State(initialValue: filament.wrappedValue.getColor())
        _weight = State(initialValue: filament.wrappedValue.weight)
        _selectedDiameter = State(initialValue: filament.wrappedValue.diameter)
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
                    
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("颜色")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !color.isEmpty {
                                Circle()
                                    .fill(selectedColor)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
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

// MARK: - 辅助视图

// 耗材盘编辑视图
struct SpoolEditorView: View {
    let index: Int
    @Binding var spool: FilamentSpool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("第\(index)盘")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(spool.remainingPercentage))%")
                    .fontWeight(.medium)
                    .foregroundColor(
                        spool.remainingPercentage >= 95 ? .green :
                            (spool.remainingPercentage > 0 ? .orange : .red)
                    )
            }
            
            // 状态选择器
            HStack {
                StatusButton(
                    title: "全新",
                    isSelected: spool.remainingPercentage >= 95,
                    color: .green
                ) {
                    spool.remainingPercentage = 100
                }
                
                StatusButton(
                    title: "部分使用",
                    isSelected: spool.remainingPercentage > 0 && spool.remainingPercentage < 95,
                    color: .orange
                ) {
                    if spool.remainingPercentage >= 95 || spool.remainingPercentage <= 0 {
                        spool.remainingPercentage = 50
                    }
                }
                
                StatusButton(
                    title: "空盘",
                    isSelected: spool.remainingPercentage <= 0,
                    color: .red
                ) {
                    spool.remainingPercentage = 0
                }
            }
            
            // 精确调整
            if spool.remainingPercentage > 0 && spool.remainingPercentage < 95 {
                VStack(spacing: 8) {
                    HStack {
                        Text("精确调整")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        ForEach([25, 50, 75], id: \.self) { value in
                            Button(action: {
                                spool.remainingPercentage = Double(value)
                            }) {
                                Text("\(value)%")
                                    .font(.caption)
                                    .foregroundColor(
                                        Int(spool.remainingPercentage) == value ? .white : .primary
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Int(spool.remainingPercentage) == value ? 
                                            Color.blue : Color.gray.opacity(0.2)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Slider(value: $spool.remainingPercentage, in: 5...90, step: 5)
                        .accentColor(.orange)
                }
                .padding(.top, 4)
            }
            
            TextField("备注（可选）", text: $spool.notes)
                .font(.caption)
                .padding(10)
                .background(SystemColorCompatibility.tertiarySystemBackground)
                .cornerRadius(8)
        }
    }
}

// 状态选择按钮
struct StatusButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(isSelected ? color : Color.clear)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: 2)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? color : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
} 

