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
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(radius: 2)
                        .onTapGesture {
                            selectedColorName = filament.color
                            selectedColor = filament.getColor()
                            showingColorPicker = true
                        }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(filament.brand)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(filament.type.rawValue)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            selectedColorName = filament.color
                            selectedColor = filament.getColor()
                            showingColorPicker = true
                        }) {
                            HStack {
                                Text(filament.color)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 详细信息卡片
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
                
                // 耗材使用量
                VStack(alignment: .leading, spacing: 15) {
                    Text("使用情况")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("剩余量")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(filament.remainingPercentage))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        UsageSlider(percentage: Binding(
                            get: { filament.remainingPercentage },
                            set: { newValue in
                                filament.remainingPercentage = newValue
                                viewModel.updateRemainingPercentage(id: filament.id, percentage: newValue)
                            }
                        ))
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
                    
                    Button(action: {
                        viewModel.markAsEmpty(id: filament.id)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("标记为用完")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
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