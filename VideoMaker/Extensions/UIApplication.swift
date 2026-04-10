import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

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

public func hideKeyboard() {
    UIApplication.shared.endEditing()
}
