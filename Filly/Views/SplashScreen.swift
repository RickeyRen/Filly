import SwiftUI

struct SplashScreen: View {
    @State private var isLoading = true
    var message: String
    var onLoadingComplete: () -> Void
    
    init(message: String = "3D打印耗材管理", onLoadingComplete: @escaping () -> Void = {}) {
        self.message = message
        self.onLoadingComplete = onLoadingComplete
    }
    
    var body: some View {
        VStack {
            Image(systemName: "cube.box.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Filly")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.isLoading = false
                    self.onLoadingComplete()
                }
            }
        }
    }
} 