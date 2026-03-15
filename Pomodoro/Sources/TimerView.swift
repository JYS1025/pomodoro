import SwiftUI

struct TimerView: View {
    @Bindable var viewModel: TimerViewModel

    private var accent: Color {
        viewModel.isStudySession
            ? Color(red: 1.0, green: 0.45, blue: 0.1)
            : Color(red: 0.1, green: 0.72, blue: 0.95)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            timerRing
            controls
            settingsCard
        }
        .frame(width: 310)
        .background(.regularMaterial)
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 7) {
                Circle()
                    .fill(accent)
                    .frame(width: 7, height: 7)
                    .shadow(color: accent.opacity(0.5), radius: 4)

                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.isStudySession ? "Study Session" : "Break Time")
                        .font(.system(size: 14, weight: .semibold))
                    Text(viewModel.isStudySession ? "Stay focused" : "Take it easy")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { NSApplication.shared.terminate(nil) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
                    .background(.primary.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 20)
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(0.07), lineWidth: 3)

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: viewModel.progress)

            Text(viewModel.timeString)
                .font(.system(size: 58, weight: .thin, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: 200, height: 200)
        .padding(.bottom, 8)
    }

    private var controls: some View {
        ZStack {
            if viewModel.isSoundPlaying {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        viewModel.acknowledgeAlarm()
                    }
                } label: {
                    Label("Stop Alarm", systemImage: "bell.slash.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(accent.opacity(0.12),
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(accent.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                HStack(spacing: 20) {
                    ControlButton(icon: "arrow.counterclockwise", action: viewModel.resetTimer)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleTimer()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(accent)
                                .frame(width: 60, height: 60)
                                .shadow(color: accent.opacity(0.35), radius: 12, y: 4)
                            Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                                .offset(x: viewModel.isTimerRunning ? 0 : 2)
                        }
                    }
                    .buttonStyle(.plain)

                    ControlButton(icon: "forward.end.fill", action: viewModel.skipSession)
                }
                .frame(height: 60)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(height: 60)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isSoundPlaying)
        .padding(.bottom, 24)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            SettingsRow {
                RowLabel(icon: "book.closed", title: "Study")
                Spacer()
                TimeField(value: $viewModel.studyMinutes, range: 1...120)
            }
            RowDivider()
            SettingsRow {
                RowLabel(icon: "cup.and.saucer", title: "Break")
                Spacer()
                TimeField(value: $viewModel.breakMinutes, range: 1...60)
            }
            RowDivider()
            SettingsRow {
                Image(systemName: viewModel.alarmVolume == 0 ? "speaker.slash" : "speaker.wave.2")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                Slider(value: $viewModel.alarmVolume, in: 0...4)
                    .tint(accent)
            }
        }
        .background(.primary.opacity(0.035),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.primary.opacity(0.07), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

// MARK: - Reusable Components

private struct ControlButton: View {
    let icon: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button { action() } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(hovered ? .primary : .secondary)
                .frame(width: 44, height: 44)
                .background(.primary.opacity(hovered ? 0.09 : 0.05), in: Circle())
                .scaleEffect(hovered ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.15)) { hovered = h } }
    }
}

private struct SettingsRow<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        HStack(spacing: 10) { content }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}

private struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.07))
            .frame(height: 1)
            .padding(.leading, 44)
    }
}

private struct RowLabel: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.primary.opacity(0.7))
        }
    }
}

private struct TimeField: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack(spacing: 2) {
            TextField("", value: $value, format: .number)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.trailing)
                .frame(width: 30)
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .background(.primary.opacity(0.06),
                             in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            Text("m")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Stepper("", value: $value, in: range)
                .labelsHidden()
                .scaleEffect(0.82)
        }
    }
}
