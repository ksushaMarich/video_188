import Foundation
import Combine

private let weeklyLimit = 10
private let trialLimit = 1
private let periodDays = 7
private let keySubscriptionStart = "generationLimitSubscriptionStart"
private let keyPeriodIndex = "generationLimitPeriodIndex"
private let keyWeeklyCount = "generationLimitWeeklyCount"
private let keyTrialUsed = "generationLimitTrialUsed"

final class GenerationLimitManager: ObservableObject {
    static let shared = GenerationLimitManager()

    @Published private(set) var generationsUsed = 0
    @Published private(set) var generationsLimit = trialLimit
    @Published private(set) var generationsRemaining = trialLimit
    @Published private(set) var canGenerate = true
    @Published private(set) var daysUntilNextReset: Int? = nil

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private init() {
        refresh(isSubscribed: false)
    }

    func refresh(isSubscribed: Bool) {
        if isSubscribed {
            var subscriptionStart = defaults.object(forKey: keySubscriptionStart) as? Date
            if subscriptionStart == nil {
                subscriptionStart = Date()
                defaults.set(subscriptionStart, forKey: keySubscriptionStart)
            }
            let start = subscriptionStart!
            let currentPeriodIndex = periodIndex(since: start)
            let storedPeriodIndex: Int
            if let raw = defaults.object(forKey: keyPeriodIndex) as? Int {
                storedPeriodIndex = raw
            } else {
                storedPeriodIndex = currentPeriodIndex
                defaults.set(currentPeriodIndex, forKey: keyPeriodIndex)
            }
            var count = defaults.integer(forKey: keyWeeklyCount)
            if currentPeriodIndex != storedPeriodIndex {
                count = 0
                defaults.set(currentPeriodIndex, forKey: keyPeriodIndex)
                defaults.set(0, forKey: keyWeeklyCount)
            }
            generationsUsed = count
            generationsLimit = weeklyLimit
            generationsRemaining = max(0, weeklyLimit - count)
            canGenerate = count < weeklyLimit
            daysUntilNextReset = daysUntilNextPeriod(since: start)
        } else {
            let used = defaults.bool(forKey: keyTrialUsed)
            generationsUsed = used ? 1 : 0
            generationsLimit = trialLimit
            generationsRemaining = used ? 0 : trialLimit
            canGenerate = !used
            daysUntilNextReset = nil
        }
    }

    private func periodIndex(since start: Date) -> Int {
        let day = calendar.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, day) / periodDays
    }

    private func daysUntilNextPeriod(since start: Date) -> Int {
        let now = Date()
        let day = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        let currentPeriod = max(0, day) / periodDays
        let nextPeriodStartDay = (currentPeriod + 1) * periodDays
        guard let nextPeriodStart = calendar.date(byAdding: .day, value: nextPeriodStartDay, to: start)
        else { return 0 }
        return max(0, calendar.dateComponents([.day], from: now, to: nextPeriodStart).day ?? 0)
    }

    func canAfford(price: Int) -> Bool {
        generationsRemaining >= price
    }

    func consumeGenerations(amount: Int, isSubscribed: Bool) {
        if isSubscribed {
            var subscriptionStart = defaults.object(forKey: keySubscriptionStart) as? Date
            if subscriptionStart == nil {
                subscriptionStart = Date()
                defaults.set(subscriptionStart, forKey: keySubscriptionStart)
            }
            let start = subscriptionStart!
            let currentPeriodIndex = periodIndex(since: start)
            let storedPeriodIndex = defaults.integer(forKey: keyPeriodIndex)
            var count = defaults.integer(forKey: keyWeeklyCount)
            if currentPeriodIndex != storedPeriodIndex {
                count = 0
                defaults.set(currentPeriodIndex, forKey: keyPeriodIndex)
            }
            count += amount
            defaults.set(count, forKey: keyWeeklyCount)
        } else {
            defaults.set(true, forKey: keyTrialUsed)
        }
        refresh(isSubscribed: isSubscribed)
    }

    func consumeGeneration(isSubscribed: Bool) {
        consumeGenerations(amount: 1, isSubscribed: isSubscribed)
    }
}
