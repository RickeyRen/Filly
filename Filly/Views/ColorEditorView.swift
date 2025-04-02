import SwiftUI

struct ColorEditorView: View {
    @Binding var isPresented: Bool
    @Binding var colorName: String
    @Binding var color: Color
    @Binding var brand: String
    @Binding var materialType: String
    
    var onSave: () -> Void
    
    @ObservedObject private var colorViewModel = ColorLibraryViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("颜色名称", text: $colorName)
                    .autocapitalization(.none)
                
                Picker("品牌", selection: $brand) {
                    Text("无").tag("")
                    ForEach(colorViewModel.availableBrands, id: \.self) { brand in
                        Text(brand).tag(brand)
                    }
                }
                
                if brand == "其他" {
                    TextField("输入品牌名称", text: $brand)
                        .autocapitalization(.none)
                }
                
                Picker("材料类型", selection: $materialType) {
                    Text("无").tag("")
                    ForEach(colorViewModel.availableMaterialTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                
                if materialType == "其他" {
                    TextField("输入材料类型", text: $materialType)
                        .autocapitalization(.none)
                }
                
                SwiftUI.ColorPicker("选择颜色", selection: $color)
                
                Button("保存") {
                    onSave()
                    isPresented = false
                }
                .disabled(colorName.isEmpty)
            }
            .navigationTitle("添加新颜色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
