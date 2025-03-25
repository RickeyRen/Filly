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
                                onUpdate: { updatedSpool in
                                    // 更新本地状态
                                    if let updatedFilament = viewModel.filaments.first(where: { $0.id == filament.id }) {
                                        filament = updatedFilament
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
    
    // 屏幕宽度
    @State private var sliderWidth: CGFloat = 0
    
    init(viewModel: FilamentViewModel, filamentId: UUID, spool: FilamentSpool, onUpdate: @escaping (FilamentSpool) -> Void) {
        self.viewModel = viewModel
        self.filamentId = filamentId
        self.spool = spool
        self.onUpdate = onUpdate
        self._tempPercentage = State(initialValue: spool.remainingPercentage)
        self._currentDragPercentage = State(initialValue: spool.remainingPercentage)
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
                
                // 快捷操作按钮
                HStack(spacing: 10) {
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
                    
                    Menu {
                        Button("全新 (100%)") {
                            viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 100)
                            onUpdate(spool)
                        }
                        
                        Button("75%") {
                            viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 75)
                            onUpdate(spool)
                        }
                        
                        Button("50%") {
                            viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 50)
                            onUpdate(spool)
                        }
                        
                        Button("25%") {
                            viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 25)
                            onUpdate(spool)
                        }
                        
                        Divider()
                        
                        Button("标记为用完", role: .destructive) {
                            viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 0)
                            onUpdate(spool)
                        }
                        
                        Button("删除", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
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
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            
                                            // 计算相对于滑块轨道的位置
                                            let dragLocation = value.location.x
                                            let relativePosition = dragLocation - horizontalPadding
                                            
                                            // 计算百分比，限制在0-100范围内
                                            let newPercentage = max(0, min(100, Double(relativePosition / trackWidth * 100)))
                                            
                                            // 实时更新UI
                                            currentDragPercentage = newPercentage
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
            .padding(.bottom, 16)
            
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
        .background(SystemColorCompatibility.secondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusColor.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                isEditingPercentage = true
            }) {
                Label("调整剩余量", systemImage: "slider.horizontal.3")
            }
            
            Button(action: {
                viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 100)
                onUpdate(spool)
            }) {
                Label("设为全新", systemImage: "circle.fill")
            }
            
            Button(action: {
                viewModel.updateSpoolPercentage(filamentId: filamentId, spoolId: spool.id, percentage: 0)
                onUpdate(spool)
            }) {
                Label("标记为用完", systemImage: "xmark.circle")
            }
            
            Button(role: .destructive, action: {
                showingDeleteConfirm = true
            }) {
                Label("删除", systemImage: "trash")
            }
        }
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("确认删除"),
                message: Text("确定要删除这盘耗材吗？"),
                primaryButton: .destructive(Text("删除")) {
                    viewModel.removeEmptySpool(filamentId: filamentId, spoolId: spool.id)
                    onUpdate(spool)
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
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
            
            // 中心孔
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 10, height: 10)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            
            // 高光效果
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
                .rotationEffect(Angle(degrees: -45))
        }
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