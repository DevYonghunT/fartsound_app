import SwiftUI
import AVFoundation

struct SoundSelectorView: View {
    @ObservedObject var fartService: FartSoundService
    @EnvironmentObject var hapticService: HapticService

    // MARK: Data (자동 + 1~10)
    private let baseOptions: [SoundSelectionMode] = {
        var arr: [SoundSelectionMode] = [.auto]
        arr.append(contentsOf: (0..<10).map { .manual(index: $0) })
        return arr
    }()

    // 무한 루프 가상 목록
    private let loopMultiplier: Int = 100
    private var baseCount: Int { baseOptions.count }
    private var totalCount: Int { baseCount * loopMultiplier }

    // 선택/스크롤 상태
    @State private var scrollPosition: Int? = nil
    @State private var selectedIndex: Int = 0

    // 레이아웃
    private let itemWidth: CGFloat = 56
    private let itemHeight: CGFloat = 52
    private let itemSpacing: CGFloat = 12
    private let visibleWidth: CGFloat = 120

    var body: some View {
        scrollContent()
            .frame(width: visibleWidth, height: itemHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onAppear(perform: setupInitialPosition)
            .onChange(of: scrollPosition, handleScrollChange)
    }

    // MARK: - Views

    @ViewBuilder
    private func scrollContent() -> some View {
        // iOS 17 스냅 스크롤
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: itemSpacing) {
                ForEach(0..<totalCount, id: \.self) { i in
                    cell(for: i)
                        .id(i) // 스냅 타깃
                        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: itemSpacing)
                            .frame(width: itemWidth)
                }
            }
            .padding(.horizontal, (visibleWidth - itemWidth) / 2) // 중앙 정렬 보정
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)               // 가장 가까운 셀에 스냅
        .scrollPosition(id: $scrollPosition, anchor: .center) // 중앙 기준
    }

    @ViewBuilder
    private func cell(for index: Int) -> some View {
        let mode: SoundSelectionMode = baseOptions[index % baseCount]
        let isSelected: Bool = (index == (scrollPosition ?? index))

        SoundCellView(
            title: shortName(for: mode),
            isSelected: isSelected,
            width: itemWidth,
            height: itemHeight
        )
        .scaleEffect(isSelected ? 1.15 : 0.92)
        .opacity(isSelected ? 1.0 : 0.7)
        .accessibilityLabel(Text(accessibilityLabel(for: mode)))
    }

    // MARK: - Logic

    private func setupInitialPosition() {
        // FartSoundService의 selectionMode를 중앙 근처 인덱스로 맵핑
        let startBaseIndex: Int
        switch fartService.selectionMode {
        case .auto:
            startBaseIndex = 0
        case .manual(let i):
            // .auto가 0번이므로 manual(0)은 1번에 해당
            startBaseIndex = max(1, min(i + 1, baseCount - 1))
        }

        let middle: Int = (totalCount / 2) - ((totalCount / 2) % baseCount)
        let start: Int = middle + startBaseIndex
        selectedIndex = start
        scrollPosition = start
    }

    private func handleScrollChange(_ old: Int?, _ newValue: Int?) {
        guard let newValue else { return }

        // 가장자리 접근 시 중앙 등가 위치로 점프
        recenterIfNeeded(current: newValue)

        // 선택 상태 반영
        let baseIndex: Int = newValue % baseCount
        let newMode: SoundSelectionMode = baseOptions[baseIndex]
        applySelection(mode: newMode)

        // 변경 피드백
        if selectedIndex != newValue {
            selectedIndex = newValue
            hapticService.selectionTick(playClickSound: true)
        }
    }

    private func recenterIfNeeded(current: Int) {
        let threshold: Int = baseCount
        let leftEdge: Int = 0 + threshold
        let rightEdge: Int = totalCount - 1 - threshold

        guard current <= leftEdge || current >= rightEdge else { return }

        let middle: Int = (totalCount / 2) - ((totalCount / 2) % baseCount)
        let baseIndex: Int = current % baseCount
        let target: Int = middle + baseIndex

        DispatchQueue.main.async {
            // 애니메이션 없이 순간 이동 → 무한 스크롤 느낌 유지
            withAnimation(.none) {
                scrollPosition = target
                selectedIndex = target
            }
        }
    }

    private func shortName(for mode: SoundSelectionMode) -> String {
        switch mode {
        case .auto: return "자동"
        case .manual(let idx): return "\(idx + 1)"
        }
    }

    private func accessibilityLabel(for mode: SoundSelectionMode) -> String {
        switch mode {
        case .auto: return "자동 선택"
        case .manual(let idx): return "사운드 \(idx + 1)"
        }
    }

    private func applySelection(mode: SoundSelectionMode) {
        // 메인 버튼에서 이 모드 기준으로 소리 재생됨
        fartService.selectionMode = mode
    }
}

// MARK: - Subview: 단순한 셀(타입 추론 완화용)
private struct SoundCellView: View {
    let title: String
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.15))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(isSelected ? 0.6 : 0.25),
                                lineWidth: isSelected ? 2 : 1)
                )

            Text(title)
                .font(.system(size: 14,
                              weight: isSelected ? .bold : .semibold,
                              design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
        }
        .frame(width: width, height: height)
    }
}
