import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var colorLibrary = ColorLibraryViewModel()
    @State private var showingColorLibrary = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("外观")) {
                    // 主题选择按钮组
                    ForEach(ThemeMode.allCases) { theme in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                themeManager.selectedTheme = theme
                            }
                        }) {
                            HStack {
                                Image(systemName: theme.iconName)
                                    .foregroundColor(themeIconColor(for: theme))
                                    .font(.system(size: 20))
                                    .frame(width: 30, height: 30)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(themeIconColor(for: theme).opacity(0.1))
                                    )
                                
                                Text(theme.rawValue)
                                    .font(.body)
                                
                                Spacer()
                                
                                if themeManager.selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14, weight: .bold))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.selectedTheme == theme ? 
                                    Color.blue.opacity(0.08) : 
                                    Color.clear)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        )
                    }
                }
                
                // 颜色库管理
                Section(header: Text("耗材管理")) {
                    Button(action: {
                        showingColorLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.blue)
                            Text("颜色库管理")
                            Spacer()
                            Text("\(colorLibrary.colors.count)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                                .frame(width: 30, height: 30)
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                )
                            
                            Text("关于应用")
                                .font(.body)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                    
                    HStack {
                        Image(systemName: "app.badge.checkmark")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                            .frame(width: 30, height: 30)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                            )
                        
                        Text("版本")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("设置")
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: themeManager.selectedTheme)
            .sheet(isPresented: $showingAbout) {
                AboutView(isPresented: $showingAbout)
            }
            .sheet(isPresented: $showingColorLibrary) {
                ColorLibraryManageView(colorLibrary: colorLibrary)
            }
        }
    }
    
    private func themeIconColor(for theme: ThemeMode) -> Color {
        switch theme {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .purple
        }
    }
}

struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Filly")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("3D打印耗材管理")
                    .font(.title3)
                
                Text("版本 1.0.0")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("© 2023 Jiawei Ren")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        isPresented = false
                    }
                }
            }
        }
    }
} 