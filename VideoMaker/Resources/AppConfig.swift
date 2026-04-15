import Foundation

enum AppConfig {
    static let appId = "6761820559"
    static let apphudToken = "app_81Hde2QMMUiXmsPLsRVXPYTWQtPxkT"

    enum Links {
        static let privacyPolicy = "https://docs.google.com/document/d/13SpM9KQUTqKYtNLtpq0VArFcW-f1MWzt4ussFl-yD1k/edit?usp=sharing"
        static let termsOfUse = "https://docs.google.com/document/d/17YNuclqj90W54UNx0PUS2h2244bO7C3QMLHBxnK1XyU/edit?usp=sharing"
        static let supportForm = "https://forms.gle/R64xP44bEQUW8vYo7"
        static let shareApp = "https://apps.apple.com/app/id\(AppConfig.appId)"
        static let review = "https://apps.apple.com/app/id\(AppConfig.appId)?action=write-review"
    }
}
