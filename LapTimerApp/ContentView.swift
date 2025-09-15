//
//  ContentView.swift
//  LapTimerApp
//
//  Created by Vaishnavi Mahajan on 9/12/25.
//

import SwiftUI
import Combine

// MARK: - Model
struct Lap: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date
    var elapsed: TimeInterval

    init(id: UUID = UUID(), name: String = "Lap", createdAt: Date = Date(), elapsed: TimeInterval) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.elapsed = elapsed
    }
}

// MARK: - ViewModel
final class TimerViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsed: TimeInterval = 0
    @Published var laps: [Lap] = []
    @Published var showingRenameForLap: Lap? = nil

    private var timer: AnyCancellable?
    private let tickInterval: TimeInterval = 0.01

    private let store = UserDefaults.standard
    private let keyElapsed = "clock.elapsed"
    private let keyIsRunning = "clock.isRunning"
    private let keyLaps = "clock.laps"

    init() {
        load()
        if isRunning { startTimer() }
    }

    func toggleStartStop() {
        isRunning.toggle()
        isRunning ? startTimer() : stopTimer()
        save()
    }

    func reset() {
        stopTimer()
        elapsed = 0
        save()
    }

    func saveLap() {
        let lap = Lap(name: "Lap \(laps.count + 1)", elapsed: elapsed)
        laps.insert(lap, at: 0)
        save()
    }

    func deleteLaps(at offsets: IndexSet) {
        laps.remove(atOffsets: offsets)
        save()
    }

    func rename(lap: Lap, to newName: String) {
        guard let idx = laps.firstIndex(of: lap) else { return }
        laps[idx].name = newName
        save()
    }

    var totalLapTime: TimeInterval { laps.reduce(0) { $0 + $1.elapsed } }

    func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick(self?.tickInterval ?? 0.01) }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func tick(_ delta: TimeInterval) {
        guard isRunning else { return }
        elapsed += delta
    }

    private func save() {
        store.set(elapsed, forKey: keyElapsed)
        store.set(isRunning, forKey: keyIsRunning)
        if let data = try? JSONEncoder().encode(laps) {
            store.set(data, forKey: keyLaps)
        }
    }

    private func load() {
        elapsed = store.double(forKey: keyElapsed)
        isRunning = store.bool(forKey: keyIsRunning)
        if let data = store.data(forKey: keyLaps),
           let saved = try? JSONDecoder().decode([Lap].self, from: data) {
            laps = saved
        }
    }
}

// MARK: - Formatter
extension TimeInterval {
    var mmSSms: String {
        let totalHundredths = Int((self * 100).rounded())
        let minutes = totalHundredths / 6000
        let seconds = (totalHundredths % 6000) / 100
        let hundredths = totalHundredths % 100
        return String(format: "%02d:%02d:%02d", minutes, seconds, hundredths)
    }
}

// MARK: - View
struct ContentView: View {
    @StateObject private var vm = TimerViewModel()
    @Namespace private var anim

    var body: some View {
        ZStack {
            BackgroundGradient()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Title
                Text("Clock")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(radius: 8)

                // Elapsed display
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28).strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 18, y: 12)

                    Text(vm.elapsed.mmSSms)
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: vm.elapsed)
                }
                .frame(height: 140)
                .padding(.horizontal)

                // Controls
                HStack(spacing: 16) {
                    // Reset button
                    Button(action: vm.reset) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2.weight(.semibold))
                            .padding(14)
                            .background(
                                Circle()
                                    .fill(.orange.gradient)
                                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                                    .shadow(color: .orange.opacity(0.5), radius: 8, y: 4)
                            )
                            .foregroundStyle(.white)
                    }

                    // Start/Stop button
                    Button(action: vm.toggleStartStop) {
                        HStack(spacing: 10) {
                            Image(systemName: vm.isRunning ? "stop.fill" : "play.fill")
                                .font(.title3.weight(.bold))
                            Text(vm.isRunning ? "Stop" : "Start")
                                .font(.headline)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .tracking(1.2)
                        }
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(vm.isRunning ? Color.red.gradient : Color.orange.gradient)
                                .matchedGeometryEffect(id: "startStop", in: anim)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.35), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: (vm.isRunning ? Color.red : Color.orange).opacity(0.5), radius: 12, y: 6)
                    }

                    // Save Lap
                    Button(action: vm.saveLap) {
                        VStack(spacing: 4) {
                            Image(systemName: "flag.checkered")
                                .font(.title2.weight(.semibold))
                            Text("Lap")
                                .font(.caption).fontWeight(.medium)
                        }
                        .padding(12)
                        .frame(width: 64, height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.35), lineWidth: 1))
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                        )
                        .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)

                // Laps list
                if vm.laps.isEmpty {
                    ContentPlaceholder()
                        .padding(.top, 8)
                } else {
                    List {
                        Section(header: Text("Laps").textCase(.uppercase)) {
                            ForEach(vm.laps) { lap in
                                LapRow(lap: lap)
                                    .contentShape(Rectangle())
                                    .onLongPressGesture(minimumDuration: 0.4) {
                                        vm.showingRenameForLap = lap
                                    }
                            }
                            .onDelete(perform: vm.deleteLaps)
                        }

                        // Total
                        Section(footer: Text("Long-press a lap to rename. Swipe left to delete.").foregroundStyle(.secondary)) {
                            HStack {
                                Label("Total", systemImage: "sum")
                                Spacer()
                                Text(vm.totalLapTime.mmSSms)
                                    .font(.system(.body, design: .rounded).monospacedDigit())
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .tint(.orange)
                }
            }
        }
        .alert("Rename Lap",
               isPresented: Binding(get: { vm.showingRenameForLap != nil },
                                    set: { if !$0 { vm.showingRenameForLap = nil } })) {
            if let lap = vm.showingRenameForLap {
                TextField("Name", text: Binding(
                    get: { lap.name },
                    set: { newVal in vm.rename(lap: lap, to: newVal) }
                ))
                Button("Done", role: .cancel) { vm.showingRenameForLap = nil }
            }
        } message: {
            Text("Give this lap a short name.")
        }
    }
}

// MARK: - Subviews
struct LapRow: View {
    let lap: Lap

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.orange.opacity(0.2))
                Image(systemName: "flag.checkered")
                    .imageScale(.small)
                    .foregroundStyle(.orange)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(lap.name.isEmpty ? "Lap" : lap.name)
                    .font(.subheadline.weight(.semibold))
                Text(lap.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(lap.elapsed.mmSSms)
                .font(.system(.body, design: .rounded).monospacedDigit())
        }
        .padding(.vertical, 4)
    }
}

struct ContentPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "stopwatch")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            Text("No laps yet")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.95))
            Text("Tap Lap to save the current time. Long-press a lap to rename it.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(colors: [Color.black, Color.orange.opacity(0.9)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}
