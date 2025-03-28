import SwiftUI

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
                // 耗材颜色和基本信息
                HStack(spacing: 20) {
                    Circle()
                        .fill(filament.getColor())
                        .frame(width: 80, height: 80)
                        // 内部深色阴影，创造凹陷感
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            filament.getColor().opacity(0.7),
                                            filament.getColor().opacity(1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 6
                                )
                                .blur(radius: 3)
                                .offset(x: 0, y: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(filament.brand)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedColorName = filament.color
                                selectedColor = filament.getColor()
                                showingColorPicker = true
                            }) {
                                Image(systemName: "eyedropper")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(filament.type.rawValue)
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
                    // 开始平滑动画序列
                    isDragging = true // 设置为拖动状态，这样UI会使用currentDragPercentage
                    
                    // 动画组合 - 同时进行特效和值变化
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)) {
                        // 特效动画
                        animatedScale = 1.05
                        animatedRotation = -5
                        shadowRadius = 12
                        glowOpacity = 0.4
                        highlightOpacity = 0.8
                        backgroundSaturation = 0.1
                    }
                    
                    // 值动画与特效动画并行，无需等待
                    withAnimation(.easeOut(duration: 0.8)) {
                        currentDragPercentage = 0 // 平滑动画到0%
                    }
                    
                    // 更新数据库中的值并结束动画
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // 更新数据库中的值
                        viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 0)
                        onUpdate(spool)
                        
                        // 结束特效 - 渐变回正常状态
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)) {
                            animatedScale = 1.0
                            animatedRotation = 0
                            shadowRadius = 5
                            glowOpacity = 0.0
                            highlightOpacity = 0.0
                            backgroundSaturation = 0.0
                        }
                        
                        // 完成后重置状态
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isDragging = false
                        }
                    }
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
                    // 高级物理感动画效果
                    print("执行删除操作: filamentId=\(filamentId), spoolId=\(spool.id)")

                    // 第一阶段：轻微震动与发光效果
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.prepare()
                    impactFeedback.impactOccurred()
                    
                    // 初始轻微震动
                    withAnimation(.interpolatingSpring(mass: 0.2, stiffness: 170, damping: 8, initialVelocity: 20)) {
                        animatedScale = 0.94
                        animatedRotation = -3
                        glowOpacity = 0.1
                    }
                    
                    // 第二阶段：弹性扩张与准备
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.interpolatingSpring(mass: 0.4, stiffness: 120, damping: 10, initialVelocity: 5)) {
                            animatedScale = 1.12
                            animatedRotation = 5
                            glowOpacity = 0.6
                            highlightOpacity = 0.9
                            shadowRadius = 15
                            backgroundSaturation = 0.15
                        }
                        
                        // 第三阶段：强调状态与浮动效果
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            // 轻微位置浮动动画
                            withAnimation(.easeInOut(duration: 0.2)) {
                                animatedRotation = -2
                            }
                            
                            // 第四阶段：融化消失效果
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation(.timingCurve(0.55, 0.055, 0.675, 0.19, duration: 0.28)) {
                                    animatedScale = 0.001
                                    animatedRotation = 90
                                    glowOpacity = 1.0
                                    shadowRadius = 2
                                    backgroundSaturation = 0.0
                                }
                                
                                // 执行实际删除
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    viewModel.removeEmptySpool(filamentId: filamentId, spoolId: spool.id)
                                    onUpdate(FilamentSpool())
                                }
                            }
                        }
                    }
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
                    .fill(Color.black.opacity(0.03 + (glowOpacity * 0.1)))
                    .offset(x: 0, y: 1)
                    .blur(radius: 2)
                
                // 高光层
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.12 + (glowOpacity * 0.4)),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
                
                // 动态光晕效果
                RoundedRectangle(cornerRadius: 16)
                    .fill(statusColor)
                    .opacity(glowOpacity)
                    .blur(radius: 8 * glowOpacity)
                    .blendMode(.screen)
                
                // 精致边框
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.7 + (highlightOpacity * 0.3)),
                                statusColor.opacity(0.3),
                                statusColor.opacity(0.5 + (highlightOpacity * 0.3))
                            ]), 
                            startPoint: .topLeading, 
                            endPoint: .bottomTrailing
                        ), 
                        lineWidth: 1.2
                    )
                    .opacity(0.4 + highlightOpacity * 0.6)
            }
        )
        .scaleEffect(animatedScale)
        .rotation3DEffect(
            .degrees(animatedRotation),
            axis: (x: 0.2, y: 1.0, z: 0.1),
            anchor: .center,
            anchorZ: 0.0,
            perspective: 0.2
        )
        .shadow(
            color: statusColor.opacity(0.2 + glowOpacity * 0.4), 
            radius: shadowRadius, 
            x: animatedRotation * 0.1, 
            y: 3
        )
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 6,
            x: 0,
            y: 3
        )
        .brightness(glowOpacity * 0.05)
        .saturation(1.0 + backgroundSaturation)
        .blur(radius: glowOpacity > 0.8 ? (glowOpacity - 0.8) * 4 : 0) // 消失时轻微模糊
        .onAppear {
            // 仅当是新添加的耗材盘时才触发动画
            if isNewlyAdded {
                startAnimationSequence()
            }
        }
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
    
    private func startAnimationSequence() {
        shouldAnimate = true
        
        // 1. 初始状态设置
        animatedScale = 0.95
        animatedRotation = -5
        shadowRadius = 2
        glowOpacity = 0.0
        highlightOpacity = 0.0
        backgroundSaturation = 0.0
        
        // 2. 第一阶段动画：弹出和旋转
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
            animatedScale = 1.05
            animatedRotation = 5
            shadowRadius = 12
            glowOpacity = 0.3
            highlightOpacity = 0.8
            backgroundSaturation = 0.1
        }
        
        // 3. 第二阶段：稳定动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.3)) {
                animatedScale = 1.02
                animatedRotation = 0
                shadowRadius = 8
                glowOpacity = 0.2
                backgroundSaturation = 0.05
            }
        }
        
        // 4. 第三阶段：脉冲光晕效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 1.2).repeatCount(3, autoreverses: true)) {
                glowOpacity = 0.4
                highlightOpacity = 1.0
            }
        }
        
        // 5. 最终阶段：回到正常状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)) {
                animatedScale = 1.0
                shadowRadius = 5
                glowOpacity = 0.0
                highlightOpacity = 0.0
                backgroundSaturation = 0.0
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

// 3D耗材盘模型
struct SpoolModel: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // 外部耗材线圈效果
            ZStack {
                // 线材缠绕效果 - 底层
                ForEach(0..<8) { i in
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.7),
                                color.opacity(0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 40, height: 3.5)
                        .offset(y: CGFloat(i) * 4.2 - 14)
                }
                
                // 线材高光
                ForEach(0..<8) { i in
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1 + (i % 3 == 0 ? 0.3 : 0)),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 40, height: 3.5)
                        .offset(y: CGFloat(i) * 4.2 - 14)
                }
            }
            .mask(
                // 线轴外轮廓形状
                ZStack {
                    Capsule()
                        .frame(width: 40, height: 38)
                    
                    // 中心空隙
                    Circle()
                        .frame(width: 12)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            )
            
            // 线轴底盘效果（左侧）
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.6),
                            Color.gray.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 15, height: 38)
                .offset(x: -16, y: 0)
                .mask(
                    Capsule()
                        .frame(width: 12, height: 38)
                )
            
            // 线轴底盘效果（右侧）
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.5),
                            Color.gray.opacity(0.3)
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 15, height: 38)
                .offset(x: 16, y: 0)
                .mask(
                    Capsule()
                        .frame(width: 12, height: 38)
                )
            
            // 中心轴
            ZStack {
                // 轴孔
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 8)
                
                // 轴孔高光
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 3, height: 3)
                    .offset(x: -1, y: -1)
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        .rotationEffect(Angle(degrees: 90))
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
} 
} } 
