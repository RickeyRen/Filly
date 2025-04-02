import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct AddFilamentView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel
    
    // Query to fetch brands directly from SwiftData, sorted by name
    @Query(sort: \SwiftDataBrand.name) private var brandsFromDB: [SwiftDataBrand]
    
    // State
    @State private var selectedBrandName: String = "" // Store the selected brand *name*
    @State private var customBrandName: String = ""
    @State private var showingCustomBrandInput: Bool = false
    @State private var selectedType = FilamentType.pla
    @State private var color = ""
    @State private var selectedColor = Color.blue
    @State private var weight = 1000.0
    @State private var selectedDiameter = FilamentDiameter.mm175
    @State private var notes = ""
    @State private var spoolCount = 1
    @State private var spoolsData: [FilamentSpool] = [FilamentSpool()]
    @State private var showingColorPicker = false
    @State private var availableMaterialTypes: [SwiftDataMaterialType] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    // Brand Picker / Custom Brand Input
                    if showingCustomBrandInput {
                        TextField("输入品牌名称", text: $customBrandName)
                            .onChange(of: customBrandName) { _, newValue in
                                selectedBrandName = newValue // Update state with custom name
                                fetchAvailableTypes(for: selectedBrandName)
                            }
                        Button("选择已有品牌") {
                            showingCustomBrandInput = false
                            // Default to first brand from DB if available
                            selectedBrandName = brandsFromDB.first?.name ?? ""
                            fetchAvailableTypes(for: selectedBrandName)
                        }
                    } else {
                        Picker("品牌", selection: $selectedBrandName) {
                            // Check if brandsFromDB is empty before iterating
                             if brandsFromDB.isEmpty {
                                 Text("数据库无品牌").tag("")
                             } else {
                                 ForEach(brandsFromDB) { brand in
                                     Text(brand.name).tag(brand.name)
                                 }
                             }
                        }
                        .onChange(of: selectedBrandName) { _, newValue in
                            fetchAvailableTypes(for: newValue)
                        }
                        
                        Button("添加自定义品牌") {
                            showingCustomBrandInput = true
                            customBrandName = ""
                            selectedBrandName = "" // Clear selection when switching to custom
                            fetchAvailableTypes(for: "")
                        }
                    }
                    
                    // Dynamic Material Type Picker
                    Picker("类型", selection: $selectedType) {
                        if availableMaterialTypes.isEmpty {
                             Text("-").tag(FilamentType.pla)
                             ForEach(FilamentType.allCases) { type in Text(type.rawValue).tag(type) }
                         } else {
                            ForEach(availableMaterialTypes) { materialType in
                                Text(materialType.name).tag(FilamentType(rawValue: materialType.name) ?? .other)
                            }
                        }
                    }
                    
                    // Color Picker Button
                    Button(action: {
                        showingColorPicker = true
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
                    .disabled(selectedBrandName.isEmpty || color.isEmpty)
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
                    .disabled(selectedBrandName.isEmpty || color.isEmpty)
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
            .onAppear {
                // Set initial brand selection from DB
                if selectedBrandName.isEmpty && !brandsFromDB.isEmpty {
                    selectedBrandName = brandsFromDB.first!.name
                }
                fetchAvailableTypes(for: selectedBrandName)
            }
        }
    }
    
    // Fetches available material types from SwiftData library based on brand name
    private func fetchAvailableTypes(for brandName: String) {
        // Find the SwiftDataBrand matching the name
        let predicate = #Predicate<SwiftDataBrand>{ $0.name == brandName }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let targetBrand = try? modelContext.fetch(descriptor).first {
            // Fetch associated material types using the ViewModel function
             availableMaterialTypes = filamentLibraryViewModel.fetchMaterialTypes(for: targetBrand, context: modelContext)
             // If types were found, try to set selectedType to the first available one
             if let firstType = availableMaterialTypes.first,
                let mappedType = FilamentType(rawValue: firstType.name) {
                 selectedType = mappedType
             } else if !availableMaterialTypes.isEmpty { // Fallback if mapping fails but types exist
                 selectedType = .other
             } else { // No types found in library, reset to default
                 selectedType = .pla 
             }
        } else {
            // Brand not found in library (e.g., custom brand), clear available types
            availableMaterialTypes = []
            selectedType = .pla // Reset to default for custom brand
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
        // Use selectedBrandName when creating the FilamentColor entry
        let brandToSave = showingCustomBrandInput ? customBrandName : selectedBrandName
        if let colorItem = colorLibrary.colors.first(where: { $0.name == color && $0.brand == brandToSave }) {
            colorData = colorItem.colorData
            colorLibrary.updateLastUsed(for: colorItem)
        } else if !color.isEmpty {
            colorData = ColorData(from: selectedColor)
             // Use brandToSave here
            let newColor = FilamentColor(name: color, color: selectedColor, brand: brandToSave, materialType: selectedType.rawValue)
            colorLibrary.addColor(newColor)
        }
        
        let newFilament = Filament(
            brand: brandToSave, // Use the correct brand name
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
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var filamentLibraryViewModel: FilamentLibraryViewModel

    // Query for brands
    @Query(sort: \SwiftDataBrand.name) private var brandsFromDB: [SwiftDataBrand]
    
    // State
    @State private var selectedBrandName: String
    @State private var customBrandName: String
    @State private var showingCustomBrandInput: Bool
    @State private var selectedType: FilamentType
    @State private var color: String
    @State private var selectedColor: Color
    @State private var weight: Double
    @State private var selectedDiameter: FilamentDiameter
    @State private var notes: String
    @State private var showingColorPicker = false
    @State private var availableMaterialTypes: [SwiftDataMaterialType] = []
    
    // --- Add missing Spool State Variables ---
    @State private var spoolCount: Int 
    @State private var spoolsData: [FilamentSpool]
    // -----------------------------------------

    init(viewModel: FilamentViewModel, colorLibrary: ColorLibraryViewModel, filament: Binding<Filament>) {
        self.viewModel = viewModel
        self.colorLibrary = colorLibrary
        self._filament = filament
        
        let initialFilament = filament.wrappedValue
        _selectedBrandName = State(initialValue: initialFilament.brand)
        _selectedType = State(initialValue: initialFilament.type)
        _color = State(initialValue: initialFilament.color)
        _selectedColor = State(initialValue: initialFilament.getColor())
        _weight = State(initialValue: initialFilament.weight)
        _selectedDiameter = State(initialValue: initialFilament.diameter)
        _notes = State(initialValue: initialFilament.notes)
        
        // --- Initialize Spool State --- 
        _spoolCount = State(initialValue: initialFilament.spools.count > 0 ? initialFilament.spools.count : 1) // Ensure at least 1
        _spoolsData = State(initialValue: initialFilament.spools.isEmpty ? [FilamentSpool()] : initialFilament.spools)
        // -----------------------------
        
        let isPotentiallyCustom = initialFilament.brand.isEmpty
        _showingCustomBrandInput = State(initialValue: isPotentiallyCustom)
        if isPotentiallyCustom {
             _customBrandName = State(initialValue: initialFilament.brand)
        } else {
             _customBrandName = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationView {
             Form {
                 Section(header: Text("基本信息")) {
                     // Brand Picker / Custom Brand Input (similar logic to Add view)
                     if showingCustomBrandInput {
                         TextField("输入品牌名称", text: $customBrandName)
                             .onChange(of: customBrandName) { _, newValue in
                                 selectedBrandName = newValue
                                 fetchAvailableTypes(for: selectedBrandName)
                             }
                         Button("选择已有品牌") {
                             showingCustomBrandInput = false
                             selectedBrandName = brandsFromDB.first?.name ?? ""
                             fetchAvailableTypes(for: selectedBrandName)
                         }
                     } else {
                         Picker("品牌", selection: $selectedBrandName) {
                              if brandsFromDB.isEmpty {
                                  Text("数据库无品牌").tag(selectedBrandName) // Keep current selection if DB empty
                              } else {
                                  ForEach(brandsFromDB) { brand in
                                      Text(brand.name).tag(brand.name)
                                  }
                              }
                         }
                         .onChange(of: selectedBrandName) { _, newValue in
                             fetchAvailableTypes(for: newValue)
                         }
                         Button("编辑为自定义品牌") {
                             showingCustomBrandInput = true
                             customBrandName = selectedBrandName // Start editing with current name
                         }
                     }

                     // Dynamic Material Type Picker
                     Picker("类型", selection: $selectedType) {
                         if availableMaterialTypes.isEmpty {
                             Text("-").tag(FilamentType.pla)
                             ForEach(FilamentType.allCases) { type in Text(type.rawValue).tag(type) }
                         } else {
                            ForEach(availableMaterialTypes) { materialType in
                                Text(materialType.name).tag(FilamentType(rawValue: materialType.name) ?? .other)
                            }
                        }
                     }

                     // Color Picker Button
                     Button(action: { showingColorPicker = true }) {
                         HStack {
                             Text("颜色")
                             Spacer()
                             if !color.isEmpty {
                                 MiniFilamentReelView(color: selectedColor)
                                     .frame(width: 30, height: 30)
                                 Text(color)
                             } else {
                                 Text("选择颜色")
                             }
                             Image(systemName: "chevron.right")
                         }
                     }
                 }

                 Section(header: Text("规格")) {
                     Picker("直径", selection: $selectedDiameter) {
                         ForEach(FilamentDiameter.allCases) { diameter in
                             Text(diameter.description).tag(diameter)
                         }
                     }
                     Stepper("重量: \(Int(weight))g", value: $weight, in: 100...10000, step: 100)
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
                     }.padding(.vertical, 8)
                     Divider().padding(.vertical, 8)
                     ForEach(0..<spoolsData.count, id: \.self) { index in
                         SpoolEditorView(
                             index: index + 1,
                             spool: $spoolsData[index]
                         )
                         .padding(.vertical, 8)
                         if index < spoolsData.count - 1 { Divider() }
                     }
                 }
                 Section(header: Text("备注")) {
                     TextEditor(text: $notes).frame(minHeight: 100)
                 }
             }
             .navigationTitle("编辑耗材")
             .toolbar {
                 #if os(iOS)
                 ToolbarItem(placement: .navigationBarLeading) { Button("取消") { presentationMode.wrappedValue.dismiss() } }
                 ToolbarItem(placement: .navigationBarTrailing) { Button("保存") { saveChanges() }.disabled(selectedBrandName.isEmpty || color.isEmpty) }
                 #elseif os(macOS)
                 ToolbarItem(placement: .cancellationAction) { Button("取消") { presentationMode.wrappedValue.dismiss() } }
                 ToolbarItem(placement: .confirmationAction) { Button("保存") { saveChanges() }.disabled(selectedBrandName.isEmpty || color.isEmpty) }
                 #endif
             }
             .sheet(isPresented: $showingColorPicker) {
                 ColorPickerView(colorLibrary: colorLibrary, selectedColorName: $color, selectedColor: $selectedColor)
             }
             .onAppear {
                 // Check if initial brand name exists in DB brands
                 if !showingCustomBrandInput && !brandsFromDB.contains(where: { $0.name == selectedBrandName }) {
                     // Initial brand is not in DB, switch to custom input
                     showingCustomBrandInput = true
                     customBrandName = selectedBrandName 
                 }
                 fetchAvailableTypes(for: selectedBrandName)
             }
        }
    }
    
    // Fetches available material types (function logic remains the same)
    private func fetchAvailableTypes(for brandName: String) {
        let predicate = #Predicate<SwiftDataBrand>{ $0.name == brandName }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let targetBrand = try? modelContext.fetch(descriptor).first {
             availableMaterialTypes = filamentLibraryViewModel.fetchMaterialTypes(for: targetBrand, context: modelContext)
              // Don't automatically change selectedType on fetch in edit mode,
              // keep the original value unless the user explicitly changes it.
        } else {
            availableMaterialTypes = []
        }
    }

    private func updateSpoolsData(newCount: Int) {
        // Keep existing data as much as possible
        if newCount > spoolsData.count {
            // Add new spools
            let newSpoolsNeeded = newCount - spoolsData.count
            spoolsData.append(contentsOf: (0..<newSpoolsNeeded).map { _ in FilamentSpool() })
        } else if newCount < spoolsData.count {
            // Remove excess spools from the end
            spoolsData.removeLast(spoolsData.count - newCount)
        }
    }

    private func saveChanges() {
        // Use selectedBrandName when updating the FilamentColor entry
        let brandToSave = showingCustomBrandInput ? customBrandName : selectedBrandName
        filament.brand = brandToSave
        filament.type = selectedType
        filament.color = color
        
        if let colorItem = colorLibrary.colors.first(where: { $0.name == color && $0.brand == brandToSave }) {
            filament.colorData = colorItem.colorData
            colorLibrary.updateLastUsed(for: colorItem)
        } else if !color.isEmpty {
            let newColorData = ColorData(from: selectedColor)
            filament.colorData = newColorData
            // Use brandToSave here
            let newColor = FilamentColor(name: color, color: selectedColor, brand: brandToSave, materialType: selectedType.rawValue)
            colorLibrary.addColor(newColor)
        }
        
        filament.weight = weight
        filament.diameter = selectedDiameter
        filament.notes = notes
        
        // --- Update filament spools --- 
        filament.spools = spoolsData
        // -----------------------------
        
        viewModel.updateFilament(filament)
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

