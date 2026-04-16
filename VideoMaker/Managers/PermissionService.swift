import AVFoundation
import Foundation
import Photos
import UIKit
import UniformTypeIdentifiers
import UserNotifications
import Combine

@MainActor
final class PermissionService: ObservableObject {
    
    @Published var showAlert: Bool = false
    @Published var alertType: PermissionType = .camera
    
    private var isAlertVisible = false
    static let shared = PermissionService()
    private init() {}
    
    // Photo

    func requestPhotoLibraryPermission() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
            
        case .denied, .restricted:
            alertType = .photoLibrary
            showAlert = true
            return false
            
        case .notDetermined:
            return await requestPhotoLibraryPermissionFromSystem()
            
        @unknown default:
            return false
        }
    }

    private func requestPhotoLibraryPermissionFromSystem() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self] status in
                let granted = status == .authorized || status == .limited
                if !granted {
                    Task { @MainActor in
                        self.alertType = .photoLibrary
                        showAlert = true
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
    
    // Camera
    
    func requestCameraUsageAccess() async -> Bool {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if currentStatus == .authorized {
            return (true)
        }

        if currentStatus == .denied || currentStatus == .restricted {
            Task { @MainActor in
                
                alertType = .camera
                showAlert = true
            }
            return false
        }

        let isGranted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { isAuthorized in
                continuation.resume(returning: isAuthorized)
            }
        }

        if isGranted {
            return true
        }

        Task { @MainActor in
            alertType = .camera
            showAlert = true
        }
        return false
    }
}
