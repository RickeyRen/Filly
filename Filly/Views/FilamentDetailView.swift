import SwiftUI

// 导入共享的耗材组件
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

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
                // 耗材基本信息和操作按钮 - 放在同一个卡片中
                VStack(alignment: .leading, spacing: 20) {
                    // 耗材颜色和基本信息
                    HStack(spacing: 20) {
                        FilamentReelView(color: filament.getColor())
                            .frame(width: 80, height: 80)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(filament.brand)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedColorName = filament.color
                                    selectedColor = filament.getColor()
                                    // 在此处设置筛选条件为当前耗材品牌和类型
                                    colorLibrary.selectedBrand = filament.brand
                                    colorLibrary.selectedMaterialType = filament.type
                                    showingColorPicker = true
                                }) {
                                    Image(systemName: "eyedropper")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text(filament.type)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(filament.color)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("共\(filament.spools.count)盘")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if filament.fullSpoolCount > 0 {
                                    Text("\(filament.fullSpoolCount)盘全新")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                
                                let partialCount = filament.remainingSpoolCount - filament.fullSpoolCount
                                if partialCount > 0 {
                                    Text("\(partialCount)盘部分使用")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    // 操作按钮
                    HStack(spacing: 16) {
                        // 编辑按钮
                        Button(action: {
                            isEditing = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16))
                                Text("编辑耗材类型")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.9, green: 0.95, blue: 1.0))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        
                        // 删除按钮
                        Button(action: {
                            showingDeleteConfirm = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16))
                                Text("删除耗材类型")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 18)
                .background(SystemColorCompatibility.systemBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.6),
                                    Color.blue.opacity(0.3),
                                    Color.blue.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .opacity(0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // 详细信息
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
                .background(SystemColorCompatibility.systemBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.5)
                                ]), 
                                startPoint: .topLeading, 
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                        .opacity(0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 耗材盘列表
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("耗材盘")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.addSpool(to: filament.id)
                            // 更新本地状态
                            if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                filament = updatedFilament
                            }
                        }) {
                            Label("添加耗材盘", systemImage: "plus.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if filament.spools.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("没有耗材盘")
                                .foregroundColor(.secondary)
                                .font(.headline)
                            
                            Button(action: {
                                viewModel.addSpool(to: filament.id)
                                // 更新本地状态
                                if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                    filament = updatedFilament
                                }
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("添加第一盘")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        // 耗材盘状态统计
                        HStack(spacing: 12) {
                            SpoolStatusItem(
                                count: filament.fullSpoolCount,
                                label: "全新",
                                icon: "circle.fill",
                                color: .green
                            )
                            
                            Divider()
                                .frame(height: 30)
                            
                            let partialCount = filament.remainingSpoolCount - filament.fullSpoolCount
                            SpoolStatusItem(
                                count: partialCount,
                                label: "部分使用",
                                icon: "circle.righthalf.filled",
                                color: .orange
                            )
                            
                            Divider()
                                .frame(height: 30)
                            
                            let emptyCount = filament.spools.count - filament.remainingSpoolCount
                            SpoolStatusItem(
                                count: emptyCount,
                                label: "已用完",
                                icon: "circle",
                                color: .red
                            )
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(SystemColorCompatibility.tertiarySystemBackground)
                        .cornerRadius(12)
                        .padding(.bottom, 10)
                        
                        // 耗材盘列表
                        ForEach(filament.spools) { spool in
                            SpoolItemView(
                                viewModel: viewModel,
                                filamentId: filament.id,
                                spool: spool,
                                onUpdate: { _ in
                                    print("触发更新UI回调")
                                    
                                    // 先检查整个耗材是否还存在
                                    if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                        print("更新耗材UI，当前有\(updatedFilament.spools.count)个耗材盘")
                                        filament = updatedFilament
                                    } else {
                                        print("耗材已被删除，返回上一级")
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            )
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(SystemColorCompatibility.systemBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.5)
                                ]), 
                                startPoint: .topLeading, 
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                        .opacity(0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("耗材详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("确认删除"),
                message: Text("确定要删除此耗材类型吗？此操作无法撤销。"),
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
                        updatedFilament.colorData = colorItem.colorData
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

// 单盘耗材视图
struct SpoolItemView: View {
    @ObservedObject var viewModel: FilamentViewModel
    let filamentId: UUID
    let spool: FilamentSpool
    let onUpdate: (FilamentSpool) -> Void
    
    @State private var showingOptions = false
    @State private var showingDeleteConfirm = false
    @State private var isEditingPercentage = false
    @State private var tempPercentage: Double
    @State private var currentDragPercentage: Double = 0
    @State private var isDragging = false
    
    // 动画状态控制
    @State private var shouldAnimate = false
    @State private var isNewlyAdded = false
    @State private var glowOpacity = 0.0
    @State private var highlightOpacity = 0.0
    @State private var animatedScale = 1.0
    @State private var animatedRotation = 0.0
    @State private var shadowRadius = 0.0
    @State private var backgroundSaturation = 0.0
    
    // 屏幕宽度
    @State private var sliderWidth: CGFloat = 0
    
    init(viewModel: FilamentViewModel, filamentId: UUID, spool: FilamentSpool, onUpdate: @escaping (FilamentSpool) -> Void) {
        self.viewModel = viewModel
        self.filamentId = filamentId
        self.spool = spool
        self.onUpdate = onUpdate
        self._tempPercentage = State(initialValue: spool.remainingPercentage)
        self._currentDragPercentage = State(initialValue: spool.remainingPercentage)
        
        // 根据ID和时间戳确定是否为新添加的耗材盘
        let isNew = spool.dateAdded.timeIntervalSinceNow > -2.0 && spool.remainingPercentage >= 100
        self._isNewlyAdded = State(initialValue: isNew)
    }
    
    // 确定耗材盘状态
    var spoolStatus: SpoolStatus {
        let percentage = isDragging ? currentDragPercentage : spool.remainingPercentage
        if percentage >= 95 {
            return .new
        } else if percentage > 0 {
            return .partiallyUsed
        } else {
            return .empty
        }
    }
    
    // 状态颜色
    var statusColor: Color {
        switch spoolStatus {
        case .new:
            return .green
        case .partiallyUsed:
            return .orange
        case .empty:
            return .red
        }
    }
    
    // 状态文本
    var statusText: String {
        switch spoolStatus {
        case .new:
            return "全新"
        case .partiallyUsed:
            return "部分使用"
        case .empty:
            return "已用完"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 耗材盘信息头部
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate(spool.dateAdded))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(Int(isDragging ? currentDragPercentage : spool.remainingPercentage))%")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(statusColor)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                // 直接编辑按钮
                Button(action: {
                    isEditingPercentage = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // 耗材盘可视化 - 圆环显示
            HStack(spacing: 16) {
                // 大圆环显示剩余量
                ZStack {
                    // 深色背景圆环（外层）
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 16)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // 进度圆环（外层）
                    Circle()
                        .trim(from: 0, to: CGFloat(isDragging ? currentDragPercentage : spool.remainingPercentage) / 100)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [statusColor, statusColor.opacity(0.7), statusColor]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(360 - 90)
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(Angle(degrees: -90))
                        .shadow(color: statusColor.opacity(0.3), radius: 2, x: 0, y: 1)
                        // 拖动时移除动画延迟
                        .animation(isDragging ? .interactiveSpring() : .spring(response: 0.3), value: isDragging ? currentDragPercentage : spool.remainingPercentage)
                    
                    // 轻微的阴影效果
                    Circle()
                        .fill(Color.white.opacity(0.01))
                        .frame(width: 70, height: 70)
                        .shadow(color: statusColor.opacity(0.2), radius: 4, x: 0, y: 0)
                    
                    // 内部圆环（浅色背景）
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    // 内部进度圆环
                    Circle()
                        .trim(from: 0, to: CGFloat(isDragging ? currentDragPercentage : spool.remainingPercentage) / 100)
                        .stroke(
                            statusColor.opacity(0.5),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: -90))
                        // 拖动时使用即时动画
                        .animation(isDragging ? .interactiveSpring() : .spring(response: 0.3), value: isDragging ? currentDragPercentage : spool.remainingPercentage)
                    
                    // 中心耗材盘模型
                    SpoolModel(color: statusColor)
                        .frame(width: 46, height: 46)
                }
                .frame(width: 90, height: 90)
                .padding(.leading, 8)
                
                // 剩余量滑块
                GeometryReader { geometry in
                    VStack(spacing: 8) {
                        // 计算可用空间，考虑边距和手柄大小
                        let horizontalPadding: CGFloat = 12
                        let handleWidth: CGFloat = 24
                        let trackWidth = geometry.size.width - (horizontalPadding * 2)
                        let trackHeight: CGFloat = 10
                        
                        ZStack(alignment: .leading) {
                            // 背景条
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: trackHeight)
                                .padding(.horizontal, horizontalPadding) // 确保背景条与百分比标记对齐
                            
                            // 进度条 - 只在有进度时显示
                            if (isDragging ? currentDragPercentage : spool.remainingPercentage) > 0 {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [statusColor.opacity(0.7), statusColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    // 修正进度条宽度计算，从左侧正好开始到手柄中心位置
                                    .frame(width: CGFloat(isDragging ? currentDragPercentage : spool.remainingPercentage) / 100.0 * trackWidth, height: trackHeight)
                                    .padding(.leading, horizontalPadding) // 与背景条左侧对齐
                                    // 移除慢动画，让进度条与手柄同步
                                    .animation(isDragging ? nil : .spring(response: 0.3), value: isDragging ? currentDragPercentage : spool.remainingPercentage)
                            }
                            
                            // 拖动手柄
                            Circle()
                                .fill(Color.white)
                                .frame(width: handleWidth, height: handleWidth)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                .overlay(
                                    Circle()
                                        .stroke(statusColor, lineWidth: 2)
                                )
                                // 精确定位手柄 - 修复垂直居中问题
                                .position(
                                    x: horizontalPadding + CGFloat(isDragging ? currentDragPercentage : spool.remainingPercentage) / 100.0 * trackWidth,
                                    y: handleWidth / 2 // 垂直居中在ZStack中
                                )
                                // 移除慢动画，让拖动更跟手
                                .animation(isDragging ? nil : .spring(response: 0.3), value: isDragging ? currentDragPercentage : spool.remainingPercentage)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            
                                            // 计算相对于滑块轨道的位置
                                            let dragLocation = value.location.x
                                            let relativePosition = dragLocation - horizontalPadding
                                            
                                            // 计算百分比，限制在0-100范围内
                                            let newPercentage = max(0, min(100, Double(relativePosition / trackWidth * 100)))
                                            
                                            // 立即更新UI，不使用动画
                                            withAnimation(.interactiveSpring()) {
                                                currentDragPercentage = newPercentage
                                            }
                                        }
                                        .onEnded { value in
                                            // 计算相对于滑块轨道的位置
                                            let dragLocation = value.location.x
                                            let relativePosition = dragLocation - horizontalPadding
                                            
                                            // 计算百分比，限制在0-100范围内
                                            let newPercentage = max(0, min(100, Double(relativePosition / trackWidth * 100)))
                                            
                                            // 更新剩余量
                                            viewModel.updateSpoolPercentage(
                                                filamentId: filamentId, 
                                                spoolId: spool.id, 
                                                percentage: newPercentage
                                            )
                                            onUpdate(spool)
                                            isDragging = false
                                        }
                                )
                        }
                        // 使整个轨道区域可点击，确保高度足够容纳手柄
                        .frame(height: handleWidth)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // 计算相对于滑块轨道的位置
                            let tapLocation = location.x
                            let relativePosition = tapLocation - horizontalPadding
                            
                            // 计算百分比，限制在0-100范围内
                            let newPercentage = max(0, min(100, Double(relativePosition / trackWidth * 100)))
                            
                            viewModel.updateSpoolPercentage(
                                filamentId: filamentId, 
                                spoolId: spool.id, 
                                percentage: newPercentage
                            )
                            onUpdate(spool)
                        }
                        
                        // 预计算每个刻度的位置，确保与滑块轨道完美对齐
                        let percentagePositions: [Int: CGFloat] = Dictionary(
                            uniqueKeysWithValues: [0, 25, 50, 75, 100].map { percentage in
                                (percentage, horizontalPadding + CGFloat(percentage) / 100.0 * trackWidth)
                            }
                        )
                        
                        // 快捷百分比标记
                        ZStack(alignment: .leading) {
                            ForEach([0, 25, 50, 75, 100], id: \.self) { value in
                                Text("\(value)%")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: true, vertical: false) // 防止文本截断
                                    .position(
                                        x: percentagePositions[value] ?? 0,
                                        y: 10 // 垂直居中
                                    )
                            }
                        }
                        .frame(height: 20)
                    }
                }
                .frame(height: 50)
                .padding(.trailing, 4) // 减少右侧内边距，确保100%显示完整
            }
            .padding(.bottom, 8)
            
            // 用完和删除按钮行
            HStack(spacing: 10) {
                // 添加"用完了"按钮
                Button(action: {
                    // 直接设置为0%而不进行动画
                    viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 0)
                    onUpdate(spool)
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                        Text("用完了")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 删除按钮
                Button(action: {
                    // 直接删除而不显示动画
                    viewModel.removeEmptySpool(filamentId: filamentId, spoolId: spool.id)
                    onUpdate(FilamentSpool())
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // 备注信息
            if !spool.notes.isEmpty {
                HStack {
                    Text(spool.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }
        }
        .background(
            ZStack {
                // 基础背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(SystemColorCompatibility.systemBackground)
                
                // 深度阴影层
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.03))
                    .offset(x: 0, y: 1)
                    .blur(radius: 2)
                
                // 高光层
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.12),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
                
                // 精致边框
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.7),
                                statusColor.opacity(0.3),
                                statusColor.opacity(0.5)
                            ]), 
                            startPoint: .topLeading, 
                            endPoint: .bottomTrailing
                        ), 
                        lineWidth: 1.2
                    )
                    .opacity(0.4)
            }
        )
        // 移除所有动画相关属性
        .shadow(
            color: statusColor.opacity(0.2), 
            radius: 5, 
            x: 0, 
            y: 3
        )
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 6,
            x: 0,
            y: 3
        )
        .contentShape(Rectangle())
        .sheet(isPresented: $isEditingPercentage) {
            SpoolPercentageAdjustSheet(
                percentage: $tempPercentage,
                onSave: {
                    viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: tempPercentage)
                    onUpdate(spool)
                }
            )
        }
    }
    
    // 移除动画序列函数
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// 3D耗材盘模型 - 用于耗材盘视图
struct SpoolModel: View {
    let color: Color
    // 恢复动画，采用更快的速度
    @State private var rotationDegree: Double = 0
    
    var body: some View {
        ZStack {
            // 耗材盘底部
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.7), color.opacity(0.9)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 34, height: 34)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
            
            // 耗材盘中央凹陷效果
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.8)]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 12
                    )
                )
                .frame(width: 22, height: 22)
            
            // 中心孔 - 快速旋转动画
            ZStack {
                // 背景圆 - 提供白色背景
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.95)
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 8
                        )
                    )
                    .frame(width: 14, height: 14)
                
                // 三等分圆环 - 高速动画
                ForEach(0..<3) { i in
                    let startAngle = Double(i) * 120 + 20 // 起始角度，加上20度偏移
                    let endAngle = startAngle + 80 // 结束角度，覆盖80度
                    
                    Circle()
                        .trim(from: startAngle / 360, to: endAngle / 360)
                        .stroke(
                            Color.black.opacity(0.8),
                            style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
                        )
                        .frame(width: 12, height: 12)
                        .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 提高旋转速度
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.5)
            
            // 高光效果 - 快速动画
            Circle()
                .trim(from: 0, to: 0.4)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: -45 + rotationDegree * 0.5))
        }
        .onAppear {
            // 使用较短的动画周期提高旋转速度
            let baseAnimation = Animation.linear(duration: 20) // 缩短动画周期
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
                rotationDegree = 360
            }
        }
    }
    
    // 获取三等分圆环的颜色
    private func getThreePartRingColor(for backgroundColor: Color, index: Int) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        // 根据背景亮度和部分索引选择不同的颜色
        switch index {
        case 0: // 第一部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.4).opacity(0.9) : 
                lighten(backgroundColor, by: 0.5).opacity(0.9)
        case 1: // 第二部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.6).opacity(0.9) : 
                lighten(backgroundColor, by: 0.7).opacity(0.9)
        case 2: // 第三部分
            return brightness > 0.5 ? 
                darken(backgroundColor, by: 0.5).opacity(0.9) : 
                lighten(backgroundColor, by: 0.6).opacity(0.9)
        default:
            return Color.gray
        }
    }
    
    // 使颜色变暗一定程度
    private func darken(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #endif
    }
    
    // 使颜色变亮一定程度
    private func lighten(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #endif
    }
    
    // 估算颜色亮度 (0-1范围)
    private func getColorBrightness(_ color: Color) -> CGFloat {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}

// 耗材盘状态枚举
enum SpoolStatus {
    case new
    case partiallyUsed
    case empty
}

// 调整剩余量的表单
struct SpoolPercentageAdjustSheet: View {
    @Binding var percentage: Double
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("调整耗材剩余量")
                    .font(.headline)
                    .padding(.top)
                
                // 剩余量数值展示
                Text("\(Int(percentage))%")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(percentage > 80 ? .green : (percentage > 20 ? .orange : .red))
                
                // 剩余量可视化
                ZStack(alignment: .leading) {
                    // 底部背景
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // 进度条
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    percentage > 80 ? .green : (percentage > 20 ? .orange : .red),
                                    percentage > 80 ? .green.opacity(0.7) : (percentage > 20 ? .orange.opacity(0.7) : .red.opacity(0.7))
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, CGFloat(percentage) / 100.0 * ScreenSizeCompatibility.mainWidth * 0.8), height: 20)
                }
                .padding(.horizontal)
                
                // 滑块
                Slider(value: $percentage, in: 0...100, step: 5) {
                    Text("剩余量")
                } minimumValueLabel: {
                    Text("0%")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("100%")
                        .font(.caption)
                }
                .padding(.horizontal)
                
                // 快捷按钮
                HStack(spacing: 12) {
                    ForEach([0, 25, 50, 75, 100], id: \.self) { value in
                        Button(action: {
                            percentage = Double(value)
                        }) {
                            Text("\(value)%")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(percentage == Double(value) ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(percentage == Double(value) ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
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

// 耗材盘状态统计项
struct SpoolStatusItem: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                    .foregroundColor(count > 0 ? .primary : .secondary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// 3D线材卷模型 - 优化性能
struct FilamentReelView: View {
    let color: Color
    // 恢复动画状态，提高动画速度
    @State private var rotationDegree: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    // 缓存计算的颜色值
    private let cachedColors: CachedColors
    
    init(color: Color) {
        self.color = color
        self.cachedColors = CachedColors(baseColor: color)
    }
    
    // 颜色缓存结构体
    private struct CachedColors {
        let lightenedColor: Color
        let darkenedColor: Color
        let borderColor: Color
        let contrastColors: [Color]
        let centerContrastColor: Color
        
        init(baseColor: Color) {
            let brightness = FilamentReelView.getColorBrightness(baseColor)
            
            self.lightenedColor = FilamentReelView.lighten(baseColor, by: 0.1)
            self.darkenedColor = FilamentReelView.darken(baseColor, by: 0.2)
            
            // 预计算边框颜色
            if brightness > 0.8 {
                self.borderColor = FilamentReelView.darken(baseColor, by: 0.7).opacity(0.9)
            } else if brightness > 0.6 {
                self.borderColor = FilamentReelView.darken(baseColor, by: 0.5).opacity(0.9)
            } else if brightness > 0.4 {
                self.borderColor = FilamentReelView.lighten(baseColor, by: 0.4).opacity(0.9)
            } else if brightness > 0.2 {
                self.borderColor = FilamentReelView.lighten(baseColor, by: 0.6).opacity(0.9)
            } else {
                self.borderColor = FilamentReelView.lighten(baseColor, by: 0.8).opacity(0.9)
            }
            
            // 预计算线条对比色 - 减少数量
            var colors: [Color] = []
            for i in 0..<5 {
                if i % 2 == 0 {
                    if brightness > 0.7 {
                        colors.append(FilamentReelView.darken(baseColor, by: 0.5).opacity(0.9))
                    } else if brightness > 0.4 {
                        colors.append(FilamentReelView.lighten(baseColor, by: 0.35).opacity(0.9))
                    } else {
                        colors.append(FilamentReelView.lighten(baseColor, by: 0.6).opacity(0.9))
                    }
                } else {
                    if brightness > 0.7 {
                        colors.append(FilamentReelView.darken(baseColor, by: 0.3).opacity(0.9))
                    } else if brightness > 0.4 {
                        colors.append(FilamentReelView.darken(baseColor, by: 0.25).opacity(0.9))
                    } else {
                        colors.append(FilamentReelView.lighten(baseColor, by: 0.4).opacity(0.9))
                    }
                }
            }
            self.contrastColors = colors
            
            // 预计算中心对比色
            if brightness > 0.5 {
                self.centerContrastColor = FilamentReelView.darken(baseColor, by: 0.6).opacity(0.9)
            } else {
                self.centerContrastColor = FilamentReelView.lighten(baseColor, by: 0.7).opacity(0.9)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 外部圆环 - 采用渐变填充增强立体感
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            cachedColors.lightenedColor,
                            color,
                            cachedColors.darkenedColor
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 38
                    )
                )
                .frame(width: 76, height: 76)
            
            // 耗材线材质感 - 提高旋转速度
            OptimizedCircleWindings(
                colorScheme: colorScheme,
                rotationDegree: rotationDegree,
                contrastColors: cachedColors.contrastColors
            )
            
            // 减少标记点的数量
            ForEach(0..<2) { i in
                let angle = Double(i) * 180.0
                let radius = 32.0
                
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .offset(
                        x: CGFloat(cos(Angle(degrees: angle + rotationDegree * 1.0).radians) * radius),
                        y: CGFloat(sin(Angle(degrees: angle + rotationDegree * 1.0).radians) * radius)
                    )
            }
            
            // 中心孔周围的边缘
            Circle()
                .stroke(cachedColors.centerContrastColor, lineWidth: 2.0)
                .frame(width: 27, height: 27)
            
            // 中心孔 - 提高旋转速度
            OptimizedCenterHole(rotationDegree: rotationDegree)
            
            // 顶部高光 - 提高旋转速度
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(
                    Color.white.opacity(0.5),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 44, height: 44)
                .rotationEffect(Angle(degrees: -20 + rotationDegree * 0.5))
                .offset(y: -7)
                .blur(radius: 3)
                
            // 最外侧边框
            Circle()
                .stroke(cachedColors.borderColor, lineWidth: 1.2)
                .frame(width: 76, height: 76)
        }
        .frame(width: 85, height: 85)
        .onAppear {
            // 使用较短的动画周期提高动画速度
            let baseAnimation = Animation.linear(duration: 20) // 缩短动画周期
            let smoothAnimation = baseAnimation.repeatForever(autoreverses: false)
            
            withAnimation(smoothAnimation) {
                rotationDegree = 360
            }
        }
    }
    
    // 静态辅助函数
    static private func lighten(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: min(1, red + amount),
            green: min(1, green + amount),
            blue: min(1, blue + amount),
            alpha: alpha
        ))
        #endif
    }
    
    static private func darken(_ color: Color, by amount: CGFloat) -> Color {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(UIColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(NSColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        ))
        #endif
    }
    
    static private func getColorBrightness(_ color: Color) -> CGFloat {
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        // 使用亮度公式: 0.299R + 0.587G + 0.114B
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}

// 提取的同心圆组件 - 优化性能
private struct OptimizedCircleWindings: View {
    let colorScheme: ColorScheme
    let rotationDegree: Double
    let contrastColors: [Color]
    
    var body: some View {
        // 减少圆圈数量以提高性能
        ForEach(0..<3) { i in // 只渲染3个圆环
            // 增加间隔减少视觉复杂度
            if i % 2 == 0 || i == 1 {
                let radius = 20.0 + CGFloat(i) * 3.5
                let rotationSpeed = i % 2 == 0 ? 1.0 : -0.8 // 提高旋转速度
                let rotationOffset = Double(i) * 60
                
                Circle()
                    .trim(from: i % 3 == 0 ? 0.0 : 0.03, to: i % 4 == 0 ? 0.97 : 1.0)
                    .stroke(
                        i % 2 == 0 ? 
                            contrastColors[i % contrastColors.count] :
                            (colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7)),
                        style: StrokeStyle(
                            lineWidth: 1.2 + (CGFloat(4-i) * 0.05),
                            lineCap: .round,
                            lineJoin: .round,
                            dash: i % 2 == 0 ? [] : [3, 3]
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(Angle(degrees: rotationOffset + rotationDegree * rotationSpeed))
            }
        }
    }
}

// 提取的中心孔组件 - 优化性能
private struct OptimizedCenterHole: View {
    let rotationDegree: Double
    
    var body: some View {
        ZStack {
            // 背景圆
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.95)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 15
                    )
                )
                .frame(width: 25, height: 25)
            
            // 三段圆环，提高旋转速度
            ForEach(0..<3) { i in
                let startAngle = Double(i) * 120 + 20 // 起始角度，每段相隔120度
                let endAngle = startAngle + 80 // 结束角度，每段覆盖80度
                
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360)
                    .stroke(
                        Color.black.opacity(0.8),
                        style: StrokeStyle(lineWidth: 4.0, lineCap: .round)
                    )
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 提高旋转速度
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 1.0, x: 0, y: 0.5)
    }
}

// 增强的3D圆柱体
struct Cylinder3D: View {
    let color: Color
    let width: CGFloat
    let depth: CGFloat
    let gradientStrength: CGFloat
    
    
    var body: some View {
        ZStack {
            // 前面圆形
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color,
                            color.opacity(1.0 - gradientStrength)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: width)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
            
            // 模拟侧面深度 - 使用多层叠加创造深度感
            let depthLayers = Int(depth/2)
            ForEach(0..<depthLayers, id: \.self) { i in
                let scale = 1.0 - CGFloat(i) * (0.5 / CGFloat(depth))
                let opacity = 1.0 - CGFloat(i) / CGFloat(depth/2) * 0.8
                
                Circle()
                    .stroke(color.opacity(opacity), lineWidth: 1)
                    .frame(width: width * scale, height: width * scale)
                    .offset(x: -CGFloat(i) * 0.5)
            }
        }
    }
}

// 耗材缠绕效果
struct FilamentWindings: View {
    let color: Color
    let width: CGFloat
    let depth: CGFloat
    let windingCount: Int
    let windingWidth: CGFloat
    
    var body: some View {
        ZStack {
            // 创建多层次的缠绕线
            ForEach(0..<windingCount, id: \.self) { i in
                let offsetZ = CGFloat(i) * (depth / CGFloat(windingCount)) - depth/2
                let opacity = 0.7 + 0.3 * sin(CGFloat(i) / CGFloat(windingCount) * .pi)
                
                Circle()
                    .stroke(
                        color.opacity(opacity),
                        lineWidth: windingWidth
                    )
                    .frame(width: width - 8, height: width - 8)
                    .offset(x: offsetZ)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 0)
            }
        }
    }
}

// 表面反光效果
struct ReflectionOverlay: View {
    let width: CGFloat
    let height: CGFloat
    let opacity: CGFloat
    
    var body: some View {
        ZStack {
            // 顶部高光
            Ellipse()
                .fill(Color.white)
                .frame(width: width * 0.4, height: width * 0.2)
                .offset(x: -width * 0.1, y: -height * 0.2)
                .blur(radius: 5)
                .blendMode(.overlay)
                .opacity(opacity * 1.2)
            
            // 侧面光泽
            Capsule()
                .fill(Color.white)
                .frame(width: width * 0.1, height: height * 0.7)
                .offset(x: width * 0.25, y: 0)
                .blur(radius: 4)
                .blendMode(.overlay)
                .opacity(opacity * 0.8)
        }
    }
}

// 圆柱体效果 - 模拟侧面视图 (保留用于其它组件)
struct Cylinder: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // 顶部椭圆
            Ellipse()
                .fill(color)
                .frame(width: width, height: width * 0.4)
                .offset(y: -height/2)
            
            // 底部椭圆
            Ellipse()
                .fill(color.opacity(0.7))
                .frame(width: width, height: width * 0.4)
                .offset(y: height/2)
            
            // 连接两个椭圆的矩形
            Rectangle()
                .fill(color.opacity(0.85))
                .frame(width: width, height: height)
            
            // 侧面高光
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .blendMode(.overlay)
        }
    }
}

// 注意: 其他组件(MiniFilamentReelView、SimpleFillamentReel2D和BreathingEffect)
// 已移至FilamentComponents.swift文件
