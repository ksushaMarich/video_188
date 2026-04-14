
enum PermissionType {
    case photoLibrary
    case camera

    var alertTitle: String {
        switch self {
            case .photoLibrary:
                return "No Photo Access"
        case .camera:
            return "No Camera Access"
        }
    }

    var alertMessage: String {
        switch self {
            case .photoLibrary:
                return "Allow access to use photos as the first frame for video generation and to save finished videos to your Camera Roll. Please go to Settings and allow access"
        case .camera:
            return "Allow access to take photos with the camera and use them as the first frame to generate a video. Please go to Settings and allow access"
        }
    }
}
