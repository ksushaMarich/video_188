import ApphudBase
import Foundation
import StoreKit

extension ApphudProduct {
    var localizedIntroductory: String? {
        introductory.map { introductory in
            switch introductory {
                case let .freeTrial(period):
                    return "\(period.format(omitOneUnit: false)) free trial"
                case let .payUpFront(price, period):
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = priceLocale
                    return "first \(period.format(omitOneUnit: false)) for \(formatter.string(from: price as NSNumber)!)"
                case let .payAsYouGo(price, period, numberOfPeriods):
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = priceLocale
                    return "first \(ProductDataPeriod(unit: period.unit, numberOfUnits: period.numberOfUnits * numberOfPeriods).format(omitOneUnit: false)) for \(formatter.string(from: price as NSNumber)!)/\(period.format(omitOneUnit: true))"
            }
        }
    }
    
    var trialPeriodText: String? {
        guard case let .freeTrial(period)? = introductory else {
            return nil
        }
        return period.format(omitOneUnit: false)
    }

    var fullPrice: String {
        var price = localizedPrice
        if let localizedSubscriptionPeriod {
            price += "/\(localizedSubscriptionPeriod)"
        } else {
            price += " at once"
        }
        if let discount = localizedIntroductory {
            price += "+\(discount)"
        }
        return price
    }

    var displayText: String {
        if isLifetime {
            return "Lifetime"
        } else if isFree {
            return "Try for free"
        } else if isTrial {
            return "Try for free"
        } else {
            return "Weekly"
        }
    }

    var revertedFullPrice: String {
        var price = ""
        price += "\(localizedPrice)"
        if let localizedSubscriptionPeriod {
            price += "/\(localizedSubscriptionPeriod)"
        } else {
            price += " at once"
        }
        if let discount = localizedIntroductory {
            price += "+ \(discount)"
        }
        return price
    }
}
