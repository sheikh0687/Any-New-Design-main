//
//  BannerCursor.swift
//  Any
//
//  Created by Arbaz  on 04/04/26.
//

import Foundation

// MARK: - Simple Banner Autoplay Engine
final class BannerAutoPlayer: ObservableObject {
    
    @Published var index: Int = 0
    private(set) var isAutoScrolling = false
//    @Published var isUserScrolling: Bool = false   // ⭐️ NEW
    
    private var timer: Timer?
    private var loopCount = 0
    private var finishedFirstLoop = false
    private var scrollStopWorkItem: DispatchWorkItem?
    private var autoplayFinished = false
    private var isSuspended = false  // for scene-phase suspend
    
    var bannerCount: Int = 0
    
    // MARK: - Start autoplay
    func start() {
        guard bannerCount > 1 else { return }
        guard !isSuspended else { return }
        guard !autoplayFinished else { return }
        guard timer == nil else { return }
        scheduleTimer()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func suspend() {          // called when app goes to background
        isSuspended = true
        stop()
    }
    
    func resume() {           // called when app returns to foreground
        isSuspended = false
        start()
    }
    
    private func scheduleTimer() {
        stop()
        guard !isSuspended, !autoplayFinished else { return }

        let interval = dwellTime()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.advance()
        }
    }

    private func advance() {
        timer = nil
        isAutoScrolling = true          // ← mark before index change
        index += 1
        if index >= bannerCount {
            index = 0
            loopCount += 1
            finishedFirstLoop = true
        }
        // Small delay — enough for scrollTo + preferenceChange to fire and settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAutoScrolling = false
        }

        if loopCount >= 2 {
            autoplayFinished = true
            return
        }
        scheduleTimer()
    }
    
    private func dwellTime() -> Double {
        let base: Double = (index == 0 && !finishedFirstLoop) ? 6 : 4
        return min(max(base, 3), 8)
    }

    private func fullReset() {
        loopCount = 0
        finishedFirstLoop = false
        autoplayFinished = false  // ← KEY: allow autoplay to restart
        timer = nil
        start()
    }

    /// Call this on ANY user interaction: tap, drag, swipe
    func notifyUserScrolled() {
        // Cancel any pending "resume" work
        scrollStopWorkItem?.cancel()
        scrollStopWorkItem = nil

        // Stop the autoplay timer immediately
        stop()

        // Schedule a restart after the user goes idle
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.scrollStopWorkItem = nil
            self.fullReset()       // resets loops + restarts cleanly
        }
        scrollStopWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
    }
}
