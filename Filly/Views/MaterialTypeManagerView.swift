import SwiftUI

struct MaterialTypeManagerView: View {
    @EnvironmentObject var typeViewModel: FilamentTypeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var newTypeName = ""
    @State private var editingType: FilamentTypeModel? = nil
    @State private var editedName = ""
    @State private var showingAddAlert = false
    @State private var showingEditAlert = false
    @State private var showingDeleteAlert = false
    @State private var typeToDelete: UUID? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("添加新类型")) {
                    HStack {
                        TextField("新材料类型名称", text: $newTypeName)
                        Button("添加") {
                            if !newTypeName.isEmpty {
                                typeViewModel.addType(name: newTypeName)
                                newTypeName = ""
                            }
                        }
                        .disabled(newTypeName.isEmpty)
                    }
                }
                
                Section(header: Text("现有材料类型")) {
                    if typeViewModel.types.isEmpty {
                        Text("无材料类型记录")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(typeViewModel.types.sorted(by: { $0.name < $1.name })) { type in
                            HStack {
                                Text(type.name)
                                Spacer()
                                Button(action: {
                                    editingType = type
                                    editedName = type.name
                                    showingEditAlert = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: {
                                    typeToDelete = type.id
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationTitle("材料类型管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("编辑类型", isPresented: $showingEditAlert) {
                TextField("类型名称", text: $editedName)
                Button("取消", role: .cancel) { }
                Button("保存") {
                    if let id = editingType?.id, !editedName.isEmpty {
                        typeViewModel.updateType(id: id, newName: editedName)
                    }
                }
            } message: {
                Text("请输入新的类型名称")
            }
            .alert("删除类型", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    if let id = typeToDelete {
                        typeViewModel.deleteType(id: id)
                    }
                }
            } message: {
                Text("确定要删除这个材料类型吗？这可能会影响使用此类型的现有耗材。")
            }
        }
    }
}

#Preview {
    MaterialTypeManagerView()
        .environmentObject(FilamentTypeViewModel())
} 