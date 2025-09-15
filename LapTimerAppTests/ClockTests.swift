//
//  ClockTests.swift
//  LapTimerApp
//
//  Created by Vaishnavi Mahajan on 9/12/25.
//

import XCTest
@testable import LapTimerApp

final class ClockTests: XCTestCase {
    func testFormatter() {
        XCTAssertEqual(TimeInterval(0).mmSSms, "00:00:00")
        XCTAssertEqual(TimeInterval(65.23).mmSSms, "01:05:23") // 1m:5s:23 hundredths
    }

    func testStartStopAndTick() {
        let vm = TimerViewModel()
        vm.isRunning = false
        vm.elapsed = 0

        vm.toggleStartStop() // start
        XCTAssertTrue(vm.isRunning)

        // simulate 1.23 seconds
        for _ in 0..<123 { vm.tick(0.01) }
        XCTAssertGreaterThan(vm.elapsed, 1.22)
        XCTAssertLessThan(vm.elapsed, 1.24)

        vm.toggleStartStop() // stop
        XCTAssertFalse(vm.isRunning)
        let frozen = vm.elapsed
        vm.tick(1.0)
        XCTAssertEqual(vm.elapsed, frozen) // no change while stopped
    }

    func testSaveLapAndTotal() {
        let vm = TimerViewModel()
        vm.isRunning = true
        vm.elapsed = 2.50
        vm.saveLap()
        vm.elapsed = 1.25
        vm.saveLap()
        XCTAssertEqual(vm.laps.count, 2)
        XCTAssertEqual(Int(vm.totalLapTime * 100), Int((2.50 + 1.25) * 100))
    }

    func testDeleteLap() {
        let vm = TimerViewModel()
        vm.laps = [Lap(elapsed: 1), Lap(elapsed: 2), Lap(elapsed: 3)]
        vm.deleteLaps(at: IndexSet(integer: 1))
        XCTAssertEqual(vm.laps.map { $0.elapsed }, [1,3])
    }

    func testRename() {
        let vm = TimerViewModel()
        let lap = Lap(elapsed: 1.0)
        vm.laps = [lap]
        vm.rename(lap: lap, to: "Warmup")
        XCTAssertEqual(vm.laps.first?.name, "Warmup")
    }
}

