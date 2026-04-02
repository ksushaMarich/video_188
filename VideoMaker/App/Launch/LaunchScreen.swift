import SwiftUI

private struct _LaunchScreenContent: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController { UIStoryboard(name: "LaunchScreen", bundle: nil)
        .instantiateInitialViewController()!
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct LaunchScreen: View {
    var body: some View {
        _LaunchScreenContent()
            .ignoresSafeArea()
    }
}

#Preview {
    LaunchScreen()
}
