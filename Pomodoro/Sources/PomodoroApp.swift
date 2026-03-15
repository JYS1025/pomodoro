import SwiftUI

@main
struct PomodoroApp: App {
    @State private var viewModel = TimerViewModel()

    var body: some Scene {
        MenuBarExtra {
            TimerView(viewModel: viewModel)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: viewModel.isStudySession ? "timer" : "cup.and.saucer.fill")
                Text(viewModel.timeString)
                    .monospacedDigit()
                    .font(.system(size: 13, weight: .medium))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
