import SwiftUI
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct FilamentDetailView: View {
    @ObservedObject var viewModel: FilamentViewModel
    @State var filament: Filament
    @State private var isEditing = false
    @State private var showingDeleteConfirm = false
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
                            Text(filament.brand)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(filament.type.name)
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
                            // 暂时禁用编辑功能
                            // isEditing = true
                            // 显示提示
                            print("编辑功能暂未实现")
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
                        .opacity(0.6) // 降低不可用按钮的透明度
                        
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
                            viewModel.addSpool(filamentId: filament.id)
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
                                viewModel.addSpool(filamentId: filament.id)
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
                title: Text("删除确认"),
                message: Text("确定要删除这个耗材及其所有料盘吗？"),
                primaryButton: .destructive(Text("删除")) {
                    viewModel.deleteFilament(id: filament.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        // 暂时注释掉 EditFilamentView 的引用，因为此视图可能尚未实现
        // 后续需要创建 EditFilamentView 或使用其他方式实现编辑功能
        /* 
        .sheet(isPresented: $isEditing) {
            EditFilamentView(viewModel: viewModel, colorLibrary: colorLibrary, filament: $filament)
        }
        */
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
                                            
                                            // 触觉反馈 - 根据百分比变化提供不同强度的触觉反馈
                                            #if os(iOS)
                                            // 检测是否有显著的百分比变化
                                            let percentageDelta = abs(newPercentage - currentDragPercentage)
                                            if percentageDelta > 1.0 {
                                                // 主要触觉反馈 - 连续拖动时的流畅反馈
                                                let feedbackGenerator = UISelectionFeedbackGenerator()
                                                feedbackGenerator.prepare()
                                                feedbackGenerator.selectionChanged()
                                            }
                                            
                                            // 在特定节点提供更明显的反馈 (0%, 25%, 50%, 75%, 100%)
                                            let keyPoints: [Double] = [0, 25, 50, 75, 100]
                                            for point in keyPoints {
                                                // 检查是否跨过了任何关键点
                                                let crossingUp = currentDragPercentage < point && newPercentage >= point
                                                let crossingDown = currentDragPercentage > point && newPercentage <= point
                                                
                                                if crossingUp || crossingDown {
                                                    // 强烈触觉反馈 - 关键节点
                                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                    impactFeedback.prepare()
                                                    impactFeedback.impactOccurred()
                                                    
                                                    // 状态变化反馈 (如从用完到部分使用，或从部分使用到全新)
                                                    if point == 0 || point == 95 {
                                                        // 状态变化时提供更强的反馈
                                                        let notificationFeedback = UINotificationFeedbackGenerator()
                                                        notificationFeedback.prepare()
                                                        notificationFeedback.notificationOccurred(point == 0 ? .warning : .success)
                                                    }
                                                    break // 只触发一次最近的关键点反馈
                                                }
                                            }
                                            #endif
                                            
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
                                            let percentage = relativePosition / trackWidth 
                                            let normalizedPercentage = max(0.0, min(1.0, percentage))
                                            let newPercentage = normalizedPercentage * 100.0
                                            
                                            // 拖动结束时的触觉反馈
                                            #if os(iOS)
                                            // 成功确认的触觉反馈
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
                                            impactFeedback.prepare()
                                            impactFeedback.impactOccurred(intensity: 0.8)
                                            
                                            // 如果是关键值，提供额外反馈
                                            if newPercentage == 0 || newPercentage == 100 || newPercentage % 25 < 1 {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    let secondaryFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                                    secondaryFeedback.impactOccurred(intensity: 0.6)
                                                }
                                            }
                                            #endif
                                            
                                            // 更新剩余量
                                            viewModel.updateSpoolPercentage(
                                                filamentId: filamentId, 
                                                spoolId: spool.id, 
                                                percentage: newPercentage
                                            )
                                            onUpdate(spool)
                                            
                                            // 重置拖动状态
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
                            let percentage = relativePosition / trackWidth 
                            let normalizedPercentage = max(0.0, min(1.0, percentage))
                            let newPercentage = normalizedPercentage * 100.0
                            
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
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    #endif
                    
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
        withAnimation(.spring(response: 1.5, dampingFraction: 0.7, blendDuration: 0.9)) {
            animatedScale = 1.05
            animatedRotation = 5
            shadowRadius = 12
            glowOpacity = 0.3
            highlightOpacity = 0.8
            backgroundSaturation = 0.1
        }
        
        // 3. 第二阶段：稳定动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.65, blendDuration: 0.9)) {
                animatedScale = 1.02
                animatedRotation = 0
                shadowRadius = 8
                glowOpacity = 0.2
                backgroundSaturation = 0.05
            }
        }
        
        // 4. 第三阶段：脉冲光晕效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            withAnimation(.easeInOut(duration: 3.6).repeatCount(3, autoreverses: true)) {
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
            
            // 中心孔 - 替换为三等分圆环
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
                
                // 三等分圆环 - 每段80度，间隔40度
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
                        .rotationEffect(Angle(degrees: -90 - rotationDegree * 1.5)) // 反向旋转，速度比外层快50%
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 0.8, x: 0, y: 0.5)
            
            // 高光效果 - 添加旋转
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
                .rotationEffect(Angle(degrees: -45 + rotationDegree))
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 24).repeatForever(autoreverses: false)) {
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
    
    // 获取与背景色形成明显对比的增强线条颜色
    private func getEnhancedContrastColor(for backgroundColor: Color, index: Int) -> Color {
        // 估算背景色亮度
        let brightness = getColorBrightness(backgroundColor)
        
        // 交替使用基于亮度的不同对比方案，增加线条之间的区分度
        if index % 2 == 0 {
            // 偶数索引的线条
            if brightness > 0.7 {
                // 亮色背景使用较深对比色
                return darken(backgroundColor, by: 0.5).opacity(0.9)
            } else if brightness > 0.4 {
                // 中等亮度背景使用适度对比色 
                return lighten(backgroundColor, by: 0.35).opacity(0.9)
            } else {
                // 暗色背景使用明显的亮色
                return lighten(backgroundColor, by: 0.6).opacity(0.9)
            }
        } else {
            // 奇数索引的线条，使用不同强度
            if brightness > 0.7 {
                // 亮色背景
                return darken(backgroundColor, by: 0.3).opacity(0.9)
            } else if brightness > 0.4 {
                // 中等亮度背景
                return darken(backgroundColor, by: 0.25).opacity(0.9)
            } else {
                // 暗色背景
                return lighten(backgroundColor, by: 0.4).opacity(0.9)
            }
        }
    }
    
    // 获取强对比边框颜色，确保边框在任何背景色上都清晰可见
    private func getStrongBorderColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        // 为所有亮度范围使用更强对比度的边框
        if brightness > 0.8 {
            // 非常亮的背景色
            return darken(backgroundColor, by: 0.7).opacity(0.9)
        } else if brightness > 0.6 {
            // 亮色背景
            return darken(backgroundColor, by: 0.5).opacity(0.9)
        } else if brightness > 0.4 {
            // 中等亮度背景
            return lighten(backgroundColor, by: 0.4).opacity(0.9)
        } else if brightness > 0.2 {
            // 中暗背景
            return lighten(backgroundColor, by: 0.6).opacity(0.9)
        } else {
            // 非常暗的背景
            return lighten(backgroundColor, by: 0.8).opacity(0.9)
        }
    }
    
    // 获取中心孔边缘的强对比色
    private func getStrongContrastColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        if brightness > 0.5 {
            // 亮色背景使用深色对比
            return darken(backgroundColor, by: 0.6).opacity(0.9)
        } else {
            // 暗色背景使用亮色对比
            return lighten(backgroundColor, by: 0.7).opacity(0.9)
        }
    }
    
    // 获取与背景色形成最佳对比的线条颜色 (原方法保留，但不使用)
    private func getContrastColor(for backgroundColor: Color, opacity: CGFloat) -> Color {
        // 估算背景色亮度
        let brightness = getColorBrightness(backgroundColor)
        
        // 根据背景色亮度调整线条颜色
        if brightness > 0.75 {
            // 非常亮的背景色，使用更深的线条
            return darken(backgroundColor, by: 0.4).opacity(opacity * 1.5)
        } else if brightness > 0.5 {
            // 中亮度背景色，使用适度深色线条
            return darken(backgroundColor, by: 0.3).opacity(opacity * 1.8)
        } else if brightness > 0.25 {
            // 中暗度背景色，使用适度亮色线条
            return lighten(backgroundColor, by: 0.3).opacity(opacity * 1.8)
        } else {
            // 非常暗的背景色，使用更亮的线条
            return lighten(backgroundColor, by: 0.4).opacity(opacity * 1.5)
        }
    }
    
    // 获取优化的边框颜色 - 增强对比度但保持和底色协调 (原方法保留，但不使用)
    private func getOptimizedBorderColor(for backgroundColor: Color) -> Color {
        let brightness = getColorBrightness(backgroundColor)
        
        // 根据亮度创建一个更加微妙的边框颜色
        if brightness > 0.75 {
            // 亮色耗材使用深色边框
            return darken(backgroundColor, by: 0.5).opacity(0.8)
        } else if brightness > 0.5 {
            // 中亮度耗材使用中等深色边框
            return darken(backgroundColor, by: 0.4).opacity(0.7)
        } else if brightness > 0.25 {
            // 中暗度耗材使用中等亮色边框
            return lighten(backgroundColor, by: 0.4).opacity(0.7)
        } else {
            // 暗色耗材使用亮色边框
            return lighten(backgroundColor, by: 0.5).opacity(0.8)
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
        
        // 使用亮度公式: 0.299R + 0.587G + 0.114B
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

// 注意: 所有动画耗材图标组件(FilamentReelView、MiniFilamentReelView、BreathingEffect)
// 及颜色处理辅助函数已移至FilamentComponents.swift文件

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
