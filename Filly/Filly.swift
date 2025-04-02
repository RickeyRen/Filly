import SwiftUI
import SwiftData

@main
struct Filly: App {
    // 初始化主题管理器
    @StateObject var themeManager = ThemeManager()
    
    // 设置SwiftData模型容器
    var modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                SwiftDataBrand.self,
                SwiftDataMaterialType.self,
                SwiftDataFilamentColor.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法设置模型容器: \(error)")
        }
    }()
    
    // 添加天瑞耗材标志，避免重复添加
    @AppStorage("addedTianruiPETGECO") var addedTianruiPETGECO: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .onAppear {
                    if !addedTianruiPETGECO {
                        // 获取ModelContext并添加天瑞PETG-ECO系列颜色
                        let context = modelContainer.mainContext
                        let viewModel = FilamentLibraryViewModel()
                        viewModel.addTianruiPETGECOColors(context: context)
                        addedTianruiPETGECO = true
                    }
                }
        }
        .modelContainer(modelContainer)
    }
} 