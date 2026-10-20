//
//  TimestampResponseTimer.swift
//  MyBaseExtension
//
//  Created by Zack-Zeng on 2026/4/15.
//

import UIKit

/*
 Timer 挂载到 Runloop，而应用退出到后台可能会被挂起，而 Runloop 也因此不会被执行，设计了一个补发机制，允许补发退到后台丢失的响应
 */
final class CountingResponseTimer {

    enum MissedResponsePolicy {
        case replayAll
        case latestOnly
    }

    typealias ResponseHandler = (_ responseCount: Int) -> Void

    private let timeInterval: TimeInterval
    private let currentRunloop: Bool
    private let missedResponsePolicy: MissedResponsePolicy
    private let responseHandler: ResponseHandler
    private var timer: Timer?
    private var initialTimer: Timer?
    private var respondedCount: Int = 0
    private var isRunning: Bool = false
    private var backgroundTimestamp: TimeInterval?
    private var nextFireTimestamp: TimeInterval?

    private var foregroundObserver: NSObjectProtocol?
    private var backgroundObserver: NSObjectProtocol?

    init(
        timeInterval: TimeInterval,
        currentRunloop: Bool = false,
        missedResponsePolicy: MissedResponsePolicy = .replayAll,
        responseHandler: @escaping ResponseHandler
    ) {
        self.timeInterval = timeInterval
        self.currentRunloop = currentRunloop
        self.missedResponsePolicy = missedResponsePolicy
        self.responseHandler = responseHandler
        registerNotificationsIfNeeded()
        start()
    }

    deinit {
        cancel()
        removeNotifications()
    }

    func start() {
        guard timeInterval > 0 else { return }
        cancelAllTimers()
        respondedCount = 0
        backgroundTimestamp = nil
        nextFireTimestamp = Date().timeIntervalSince1970 + timeInterval
        isRunning = true
        scheduleRepeatingTimer()
    }

    func cancel() {
        isRunning = false
        respondedCount = 0
        backgroundTimestamp = nil
        nextFireTimestamp = nil
        cancelAllTimers()
    }

    func pause() {
        isRunning = false
        cancelAllTimers()
    }

    func resume() {
        isRunning = true
        resumeFrom(referenceTimestamp: Date().timeIntervalSince1970)
    }

    var currentResponseCount: Int {
        return respondedCount
    }

    private func scheduleRepeatingTimer() {
        guard isRunning, timeInterval > 0 else { return }
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(handleTimerTick), userInfo: nil, repeats: true)
        if currentRunloop {
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
        self.timer = timer
    }

    private func scheduleInitialTimer(interval: TimeInterval) {
        guard isRunning, interval > 0 else { return }
        let timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(handleInitialTimerTick), userInfo: nil, repeats: false)
        if currentRunloop {
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
        self.initialTimer = timer
    }

    private func cancelAllTimers() {
        timer?.invalidate()
        timer = nil
        initialTimer?.invalidate()
        initialTimer = nil
    }

    @objc private func handleTimerTick() {
        fireNextResponse()
    }

    @objc private func handleInitialTimerTick() {
        initialTimer?.invalidate()
        initialTimer = nil
        fireNextResponse()
        scheduleRepeatingTimer()
    }

    private func resumeFrom(referenceTimestamp: TimeInterval) {
        guard isRunning, backgroundTimestamp != nil else { return }
        guard let nextFireTimestamp = nextFireTimestamp else {
            self.backgroundTimestamp = nil
            return
        }

        let remaining = nextFireTimestamp - referenceTimestamp
        guard remaining <= 0 else {
            self.backgroundTimestamp = nil
            cancelAllTimers()
            scheduleInitialTimer(interval: remaining)
            return
        }

        cancelAllTimers()
        let missedResponseCount = Int(floor((-remaining) / timeInterval)) + 1

        switch missedResponsePolicy {
        case .replayAll:
            for responseCount in (respondedCount + 1)...(respondedCount + missedResponseCount) {
                responseHandler(responseCount)
            }
        case .latestOnly:
            responseHandler(respondedCount + missedResponseCount)
        }

        respondedCount += missedResponseCount
        self.nextFireTimestamp = nextFireTimestamp + (Double(missedResponseCount) * timeInterval)
        self.backgroundTimestamp = nil
        let nextRemaining = max(self.nextFireTimestamp! - referenceTimestamp, 0)
        if nextRemaining == 0 {
            scheduleRepeatingTimer()
        } else {
            scheduleInitialTimer(interval: nextRemaining)
        }
    }

    private func registerNotificationsIfNeeded() {
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDidBecomeActive()
        }
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDidEnterBackground()
        }
    }

    private func removeNotifications() {
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
            self.foregroundObserver = nil
        }
        if let backgroundObserver = backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
            self.backgroundObserver = nil
        }
    }

    private func handleDidBecomeActive() {
        guard isRunning else { return }
        resumeFrom(referenceTimestamp: Date().timeIntervalSince1970)
    }

    private func handleDidEnterBackground() {
        guard isRunning else { return }
        backgroundTimestamp = Date().timeIntervalSince1970
        cancelAllTimers()
    }

    private func fireNextResponse() {
        respondedCount += 1
        responseHandler(respondedCount)
        nextFireTimestamp = Date().timeIntervalSince1970 + timeInterval
    }
}
