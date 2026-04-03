import SwiftUI

extension UIApplication {

    var topViewController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topController = window.rootViewController
        else { return nil }

        while let presented = topController.presentedViewController {
            topController = presented
        }
        return topController
    }
}
