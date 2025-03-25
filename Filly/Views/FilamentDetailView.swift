import SwiftUI

struct FilamentDetailView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @State var filament: Filament
    @State private var isEditing = false
    @State private var showingDeleteConfirm = false
    @State private var showingColorPicker = false
    @State private var selectedColorName = ""
    @State private var selectedColor = Color.gray
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 耗材颜色和基本信息
                HStack(spacing: 20) {
                    Circle()
                        .fill(filament.getColor())
                        .frame(width: 80, height: 80)
                        // 内部深色阴影，创造凹陷感
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            filament.getColor().opacity(0.7),
                                            filament.getColor().opacity(1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 6
                                )
                                .blur(radius: 3)
                                .offset(x: 0, y: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(filament.brand)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedColorName = filament.color
                                selectedColor = filament.getColor()
                                showingColorPicker = true
                            }) {
                                Image(systemName: "eyedropper")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(filament.type.rawValue)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(filament.color)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("共\(filament.spools.count)盘")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if filament.fullSpoolCount > 0 {
                                Text("\(filament.fullSpoolCount)盘全新")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            
                            let partialCount = filament.remainingSpoolCount - filament.fullSpoolCount
                            if partialCount > 0 {
                                Text("\(partialCount)盘部分使用")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                // 详细信息
                VStack(alignment: .leading, spacing: 15) {
                    Text("详细信息")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    DetailRow(title: "直径", value: filament.diameter.description)
                    DetailRow(title: "重量", value: "\(filament.weight)g")
                    DetailRow(title: "添加日期", value: formattedDate(filament.dateAdded))
                    
                    if !filament.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("备注")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(filament.notes)
                                .font(.body)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 耗材盘列表
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("耗材盘")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.addSpool(to: filament.id)
                            // 更新本地状态
                            if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                filament = updatedFilament
                            }
                        }) {
                            Label("添加", systemImage: "plus.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if filament.spools.isEmpty {
                        Text("没有耗材盘")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(filament.spools) { spool in
                            SpoolItemView(
                                viewModel: viewModel,
                                filamentId: filament.id,
                                spool: spool,
                                onUpdate: { updatedSpool in
                                    // 更新本地状态
                                    if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                        filament = updatedFilament
                                    }
                                }
                            )
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 操作按钮
                VStack(spacing: 15) {
                    Button(action: {
                        isEditing = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("编辑耗材")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingDeleteConfirm = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除耗材")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("耗材详情")
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("确认删除"),
                message: Text("确定要删除此耗材吗？此操作无法撤销。"),
                primaryButton: .destructive(Text("删除")) {
                    viewModel.deleteFilament(id: filament.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isEditing) {
            EditFilamentView(viewModel: viewModel, colorLibrary: colorLibrary, filament: $filament)
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(
                colorLibrary: colorLibrary,
                selectedColorName: $selectedColorName,
                selectedColor: $selectedColor
            )
            .onDisappear {
                if selectedColorName != filament.color {
                    // 更新颜色
                    var updatedFilament = filament
                    updatedFilament.color = selectedColorName
                    
                    // 查找匹配的颜色数据
                    if let colorItem = colorLibrary.colors.first(where: { $0.name == selectedColorName }) {
                        updatedFilament.colorData = colorItem.color
                        colorLibrary.updateLastUsed(for: colorItem)
                    } else {
                        // 创建新的颜色数据
                        updatedFilament.colorData = ColorData(from: selectedColor)
                        
                        // 添加到颜色库
                        let newColor = FilamentColor(name: selectedColorName, color: selectedColor)
                        colorLibrary.addColor(newColor)
                    }
                    
                    viewModel.updateFilament(updatedFilament)
                    filament = updatedFilament
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// 单盘耗材视图
struct SpoolItemView: View {
    @ObservedObject var viewModel: FilamentViewModel
    let filamentId: UUID
    let spool: FilamentSpool
    let onUpdate: (FilamentSpool) -> Void
    
    @State private var showingOptions = false
    @State private var showingDeleteConfirm = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("添加日期: \(formattedDate(spool.dateAdded))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingOptions = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .confirmationDialog("耗材盘选项", isPresented: $showingOptions) {
                    Button("标记为用完") {
                        viewModel.removeEmptySpool(filamentId: filamentId, spoolId: spool.id)
                        onUpdate(spool)
                    }
                    
                    Button("删除", role: .destructive) {
                        showingDeleteConfirm = true
                    }
                    
                    Button("取消", role: .cancel) { }
                }
                .alert(isPresented: $showingDeleteConfirm) {
                    Alert(
                        title: Text("确认删除"),
                        message: Text("确定要删除这盘耗材吗？"),
                        primaryButton: .destructive(Text("删除")) {
                            viewModel.removeEmptySpool(filamentId: filamentId, spoolId: spool.id)
                            onUpdate(spool)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            HStack {
                Text("\(Int(spool.remainingPercentage))%")
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(spool.remainingPercentage >= 100 ? "全新" : "部分使用")
                    .font(.caption)
                    .foregroundColor(spool.remainingPercentage >= 100 ? .green : .orange)
            }
            
            UsageSlider(percentage: Binding(
                get: { spool.remainingPercentage },
                set: { newValue in
                    viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: newValue)
                    onUpdate(spool)
                }
            ))
            
            if !spool.notes.isEmpty {
                Text(spool.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

struct UsageSlider: View {
    @Binding var percentage: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: getProgressColor(percentage: percentage)))
            
            Slider(value: $percentage, in: 0...100, step: 5)
                .accentColor(getProgressColor(percentage: percentage))
        }
    }
    
    private func getProgressColor(percentage: Double) -> Color {
        if percentage < 30 {
            return .red
        } else if percentage < 70 {
            return .orange
        } else {
            return .green
        }
    }
} 