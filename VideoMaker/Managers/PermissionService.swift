import AVFoundation
import Foundation
import Photos
import UIKit
import UniformTypeIdentifiers
import UserNotifications
import Combine

@MainActor
final class PermissionService: ObservableObject {
    private var isAlertVisible = false
    static let shared = PermissionService()
    private init() {}

    func requestPhotoLibraryPermission() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .authorized, .limited:
                return true

            case .denied, .restricted:
                await showSettingsAlert(for: .photoLibrary)
                return false

            case .notDetermined:
                return await requestPhotoLibraryPermissionFromSystem()

            @unknown default:
                return false
        }
    }

    private func requestPhotoLibraryPermissionFromSystem() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                let granted = status == .authorized || status == .limited
                if !granted {
                    Task { @MainActor in
                        await self.showSettingsAlert(for: .photoLibrary)
                    }
                }
                continuation.resume(returning: granted)
            }
        }
    }

    func checkPhotoLibraryPermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
    }

    private func showSettingsAlert(for permission: PermissionType) {
        guard !isAlertVisible else { return }
        isAlertVisible = true

        guard let topVC = topViewController() else {
            isAlertVisible = false
            return
        }

        let alert = UIAlertController(
            title: permission.alertTitle,
            message: permission.alertMessage,
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isAlertVisible = false
        })
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.isAlertVisible = false
            self.openAppSettings()
        })

        topVC.present(alert, animated: true)
    }

    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    private func topViewController(base: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?
        .rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}

enum PermissionType {
    case photoLibrary

    var alertTitle: String {
        switch self {
            case .photoLibrary:
                return "No access to Photos"
        }
    }

    var alertMessage: String {
        switch self {
            case .photoLibrary:
                return "We need access to your photos to use your images as the first frame and to save your generated videos"
        }
    }
}
