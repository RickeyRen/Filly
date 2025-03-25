import SwiftUI

struct FilamentListView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @State private var showingAddFilament = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
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
                        
                        Button {
                            viewModel.markAsEmpty(id: filament.id)
                        } label: {
                            Label("用完", systemImage: "xmark.circle")
                        }
                        .tint(.orange)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索耗材")
            .navigationTitle("耗材库存")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFilament = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFilament) {
                AddFilamentView(viewModel: viewModel)
            }
        }
    }
    
    var filteredFilaments: [Filament] {
        if searchText.isEmpty {
            return viewModel.filaments
        } else {
            return viewModel.filaments.filter { filament in
                filament.brand.localizedCaseInsensitiveContains(searchText) ||
                filament.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
                filament.color.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct FilamentRowView: View {
    let filament: Filament
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(getColorFromName(filament.color))
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(filament.brand)
                    .font(.headline)
                
                HStack {
                    Text(filament.type.rawValue)
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
                Text("\(Int(filament.remainingPercentage))%")
                    .fontWeight(.medium)
                
                ProgressView(value: filament.remainingPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: getProgressColor(percentage: filament.remainingPercentage)))
                    .frame(width: 50)
            }
        }
        .padding(.vertical, 4)
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