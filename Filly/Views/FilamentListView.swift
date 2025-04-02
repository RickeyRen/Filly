import SwiftUI

// 导入动态图标组件
// import Foundation

struct FilamentListView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @ObservedObject var colorLibrary: ColorLibraryViewModel
    @State private var searchText = ""
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredFilaments) { filament in
                    NavigationLink(destination: FilamentDetailView(viewModel: viewModel, colorLibrary: colorLibrary, filament: filament)) {
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
            .searchable(text: $searchText, prompt: "搜索耗材")
            .navigationTitle("我的耗材")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedTab = 1
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #elseif os(macOS)
                ToolbarItem {
                    Button {
                        selectedTab = 1
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
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