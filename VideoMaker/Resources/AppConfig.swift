import Foundation

enum AppConfig {
    static let appId = ""
    static let apphudToken = "app_e6UQUvzF8n1E5Aex5JMYy3gYSctB25"

    enum Links {
        static let privacyPolicy = ""
        static let termsOfUse = ""
        static let shareApp = "https://apps.apple.com/app/id\(AppConfig.appId)"
        static let review = "https://apps.apple.com/app/id\(AppConfig.appId)?action=write-review"
    }
}
