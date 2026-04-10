
enum PermissionType {
    case photoLibrary
    case camera

    var alertTitle: String {
        switch self {
            case .photoLibrary:
                return "No Access to Photos"
        case .camera:
            return "No Camera Access"
        }
    }

    var alertMessage: String {
        switch self {
            case .photoLibrary:
                return "Allowing access lets you use photos as the first frame for video generation and save finished videos to your Camera Roll. Please go to Settings and allow access"
        case .camera:
            return "Allowing access will let you take photos with the camera and use them as the first frame to generate a video. Please go to Settings and allow access"
        }
    }
}
