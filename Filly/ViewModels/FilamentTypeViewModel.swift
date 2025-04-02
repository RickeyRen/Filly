import Foundation
import SwiftUI

class FilamentTypeViewModel: ObservableObject {
    private let fileManager = FileManager.default
    private let fileName = "filamentTypes.json"
    
    // 所有材料类型的集合
    @Published var types: [FilamentTypeModel] = []
    
    init() {
        loadTypes()
    }
    
    // MARK: - 数据加载与保存
    
    // 从文件加载材料类型列表
    func loadTypes() {
        guard let url = getFileURL() else { return }
        
        if !fileManager.fileExists(atPath: url.path) {
            // 如果文件不存在，则初始化默认类型
            initializeDefaultTypes()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            types = try decoder.decode([FilamentTypeModel].self, from: data)
        } catch {
            print("加载材料类型出错: \(error)")
            // 如果加载失败，则初始化默认类型
            initializeDefaultTypes()
        }
    }
    
    // 保存材料类型列表到文件
    func saveTypes() {
        guard let url = getFileURL() else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(types)
            try data.write(to: url)
        } catch {
            print("保存材料类型出错: \(error)")
        }
    }
    
    // 初始化默认材料类型
    private func initializeDefaultTypes() {
        // 将旧的枚举转换为模型实例
        types = FilamentType.allCases.map { FilamentTypeModel.from($0) }
        saveTypes() // 保存到文件
    }
    
    // 获取文件URL
    private func getFileURL() -> URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - 材料类型操作
    
    // 添加新材料类型
    func addType(name: String) {
        // 检查是否已存在相同名称的类型
        if !types.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            let newType = FilamentTypeModel(name: name)
            types.append(newType)
            saveTypes()
        }
    }
    
    // 删除材料类型
    func deleteType(id: UUID) {
        types.removeAll { $0.id == id }
        saveTypes()
    }
    
    // 更新材料类型
    func updateType(id: UUID, newName: String) {
        if let index = types.firstIndex(where: { $0.id == id }) {
            types[index].name = newName
            saveTypes()
        }
    }
    
    // 通过名称查找材料类型
    func findType(name: String) -> FilamentTypeModel? {
        return types.first { $0.name.lowercased() == name.lowercased() }
    }
    
    // 通过ID查找材料类型
    func findType(id: UUID) -> FilamentTypeModel? {
        return types.first { $0.id == id }
    }
    
    // 如果找不到，则创建新的材料类型
    func findOrCreateType(name: String) -> FilamentTypeModel {
        if let existingType = findType(name: name) {
            return existingType
        } else {
            let newType = FilamentTypeModel(name: name)
            types.append(newType)
            saveTypes()
            return newType
        }
    }
} 