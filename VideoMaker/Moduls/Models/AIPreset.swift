import SwiftUI

enum AIPreset: String, CaseIterable, Identifiable {
    case aquraium
    case angelWings
    case flameOn
    case attackOfClones
    case turningMetal
    case dancing

    case muscleBurst
    case longHair

    case zoomIn
    case arcRight
    case rotation3D
    case zoomOut

    var id: String { rawValue }

    var title: String {
        switch self {
            case .aquraium: return "Aquraium"
            case .angelWings: return "Angel wings"
            case .flameOn: return "Flame on"
            case .attackOfClones: return "Attack of clones"
            case .turningMetal: return "Turning metal"
            case .dancing: return "Dancing"
            case .muscleBurst: return "Muscle burst"
            case .longHair: return "Long hair"
            case .zoomIn: return "Zoom in"
            case .arcRight: return "Arc right"
            case .rotation3D: return "3D rotation"
            case .zoomOut: return "Zoom out"
        }
    }

    var image: ImageResource {
        switch self {
            case .aquraium: .aquraium
            case .angelWings: .angelWings
            case .flameOn: .flameOn
            case .attackOfClones: .attackOfClones
            case .turningMetal: .turningMetal
            case .dancing: .dancing
            case .muscleBurst: .muscleBurst
            case .longHair: .longHair
            case .zoomIn: .zoomIn
            case .arcRight: .arcRight
            case .rotation3D: .rotation3D
            case .zoomOut: .zoomOut
        }
    }

    var videoURL: URL? {
        let fileName: String
        switch self {
            case .aquraium:
                fileName = "aezakmigroup_httpss.mj.runAhYO-4EZud4_Water_filling_the_scene_393820ba-5237-43cd-8cce-f4e8f90e0934_1-2"
            case .angelWings:
                fileName = "aezakmigroup_httpss.mj.runTpwQGSZXIao_Large_angel_wings_growi_7fc84118-1acf-4e44-ac8b-571023789910_1-2 2"
            case .flameOn:
                fileName = "aezakmigroup_httpss.mj.runFzEHTE2Se10_Body_igniting_from_insi_37052c7d-1039-464c-bc6c-9f60f9f474ba_1-2"
            case .attackOfClones:
                fileName = "aezakmigroup_httpss.mj.runuQIDCET3s2E_Multiple_identical_huma_94604fad-2f74-4b3e-9dc4-c790625f4ec2_1-2"
            case .turningMetal:
                fileName = "aezakmigroup_httpss.mj.runDZGa5z-6OC4_Skins_slowly_transformi_0ff03308-369a-42ec-9b9b-7465a3a11662_3-2 2"
            case .dancing:
                fileName = "aezakmigroup_httpss.mj.runOsGogD-XzV8_Character_suddenly_brea_aadf73e8-015c-491d-8c76-f29374f2ccf4_0-2"
            case .muscleBurst:
                fileName = "aezakmigroup_httpss.mj.runG2Qbsm5NGUM_Character_confidently_p_60683f91-fbfe-4a6b-ba2d-d8b691311f20_3-2"
            case .longHair:
                fileName = "aezakmigroup_httpss.mj.run77I0xBYEf7M_Hair_visibly_growing_lo_2030a1fe-e361-4180-98c2-361aac9a7cc8_1-2"
            case .zoomIn:
                fileName = "aezakmigroup_httpss.mj.rune0vMp-DGDWY_Smooth_camera_push_forw_a45fc02c-dd8d-49b8-ae05-e84774d24189_2-2"
            case .arcRight:
                fileName = "aezakmigroup_httpss.mj.runM-Rds7LhR5k_Camera_moving_in_a_smoo_fc78aa15-0595-43f4-9559-ae7cdb7faab2_3-2"
            case .rotation3D:
                fileName = "aezakmigroup_httpss.mj.runQpwHb_qZPbw_Ultra-realistic_human_c_90bae603-a3f1-49b2-aa7e-f089e2eb7795_2-2"
            case .zoomOut:
                fileName = "aezakmigroup_httpss.mj.runGr3oNcC61P8_Smooth_camera_pull_back_61acb707-cfb6-468c-b9fb-012ef6d176b0_3-2"
        }

        return Bundle.main.url(forResource: fileName, withExtension: "mp4")
    }
}

extension AIPreset {
    var presetPrompt: String {
        switch self {
            case .rotation3D:
                return """
                Ultra-realistic human character, neutral standing pose, subject completely still, no rotation, no movement, no animation, eyes forward, natural proportions, realistic skin and clothing textures. Camera orbits 360 degrees around the stationary subject, camera movement only, camera locked on subject center, constant radius from subject, eye-level angle, smooth clockwise path, starts front view, moves to right profile, back view, left profile, returns to front view. Seamless cinematic loop.
                """

            case .angelWings:
                return """
                Large angel wings growing from the back, feathers forming dynamically in layers, subtle wind blowing through feathers, glowing soft aura around the body, golden particles floating, epic cinematic lighting, smooth transformation from first frame.
                """

            case .aquraium:
                return """
                Water filling the scene gradually, floating air bubbles rising slowly, hair and clothes moving underwater, soft blue light rays from above, fish swimming around naturally, caustic light reflections on skin, peaceful slow motion.
                """

            case .arcRight:
                return """
                Camera moving in a smooth arc to the right around the subject, maintaining focus on the character, slight perspective shift creating depth, natural parallax in background, cinematic smooth camera movement.
                """

            case .attackOfClones:
                return """
                Multiple identical human copies emerging from the original case, digital glitch particles, duplicates appearing one after another, synchronized movement, chromatic aberration, cinematic lighting.
                """

            case .dancing:
                return """
                Character suddenly breaking into fluid high-energy dance, dynamic camera following rhythm, subtle slow motion accents, vibrant lighting changes synced to movement.
                """

            case .flameOn:
                return """
                Body igniting from inside out, flames spreading across skin, glowing cracks of molten light, heat distortion in the air, sparks and embers floating, dramatic cinematic lighting.
                """

            case .longHair:
                return """
                Hair growing dramatically longer with smooth flowing motion, strands forming naturally with realistic physics, cinematic lighting and slow motion transformation.
                """

            case .muscleBurst:
                return """
                Character confidently pulling the shirt upward revealing a muscular upper body, defined chest and abs, dramatic fitness lighting highlighting muscles.
                """

            case .turningMetal:
                return """
                Skin slowly transforming into liquid chrome metal, reflective surface forming in waves, realistic reflections reacting to studio lighting.
                """

            case .zoomIn:
                return """
                Smooth cinematic camera push forward toward the subject, increasing depth perspective and background blur, stable professional camera movement.
                """

            case .zoomOut:
                return """
                Smooth cinematic camera pull backward revealing more environment, expanding field of view with stable framing.
                """
        }
    }
}
