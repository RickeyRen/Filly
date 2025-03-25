import SwiftUI

struct FilamentDetailView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @State var filament: Filament
    @State private var isEditing = false
    @State private var showingDeleteConfirm = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 耗材颜色和基本信息
                HStack(spacing: 20) {
                    Circle()
                        .fill(getColorFromName(filament.color))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(filament.brand)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(filament.type.rawValue)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(filament.color)
                            .font(.title3)
                            .foregroundColor(.secondary)
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
            EditFilamentView(viewModel: viewModel, filament: $filament)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func getColorFromName(_ name: String) -> Color {
        // 这里是一个简单的映射，实际应用中可以更复杂
        let lowerName = name.lowercased()
        
        if lowerName.contains("黑") || lowerName.contains("black") {
            return .black
        } else if lowerName.contains("白") || lowerName.contains("white") {
            return .white
        } else if lowerName.contains("红") || lowerName.contains("red") {
            return .red
        } else if lowerName.contains("蓝") || lowerName.contains("blue") {
            return .blue
        } else if lowerName.contains("绿") || lowerName.contains("green") {
            return .green
        } else if lowerName.contains("黄") || lowerName.contains("yellow") {
            return .yellow
        } else if lowerName.contains("紫") || lowerName.contains("purple") {
            return .purple
        } else if lowerName.contains("橙") || lowerName.contains("orange") {
            return .orange
        } else if lowerName.contains("灰") || lowerName.contains("gray") {
            return .gray
        } else if lowerName.contains("透明") || lowerName.contains("clear") {
            return Color(white: 0.9, opacity: 0.5)
        } else {
            return .gray
        }
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