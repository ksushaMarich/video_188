import SwiftUI

enum EffectType: String, CaseIterable, Identifiable {
    case chromeMelt = "Liquid Chrome\nMelt"
    case pixelDissolve = "Pixel Dissolve\nTransition"
    case timeFreeze = "Time Slice Freeze"
    case diorama = "Miniature Diorama\nWorld"
    case overgrowth = "Nature\nOvergrowth\nTakeover"
    case speedTrails = "Hyper-Speed\nMotion Trails"

    var id: String { rawValue }
    
    var prompt: String {
        switch self {
        case .chromeMelt:
            return "A person standing still as their body transforms into liquid chrome, reflective metallic surface, slow dripping motion, high detail, studio lighting, cinematic, ultra realistic, 4k"
        case .pixelDissolve:
            return "A subject breaking apart into glowing digital pixels, dissolving into the environment, smooth transition, glitch aesthetic, vibrant colors"
        case .timeFreeze:
            return "A frozen action moment, camera orbiting around the subject, slight particle movement, dramatic lighting, cinematic slow motion, hyper detailed, matrix-style effect"
        case .diorama:
            return "A real-world scene transforming into a miniature diorama, tilt-shift lens effect, tiny details, soft lighting, toy-like appearance, whimsical, cinematic depth of field"
        case .overgrowth:
            return "Vines and plants rapidly growing over buildings and objects, nature reclaiming the scene, time-lapse effect, lush greenery, cinematic lighting, highly detailed"
        case .speedTrails:
            return "A person running at super speed, leaving glowing light trails behind, motion blur, dynamic camera tracking, futuristic energy streaks, high contrast, cinematic"
        }
    }
    
    var fileName: String {
        switch self {
        case .chromeMelt:
            return "liquid chrome"
        case .pixelDissolve:
            return "Pixel Dissolve Transition"
        case .timeFreeze:
            return "Time Slice Freeze"
        case .diorama:
            return "Miniature Diorama World"
        case .overgrowth:
            return "Nature Overgrowth Takeover"
        case .speedTrails:
            return "Hyper-Speed Motion Trails"
        }
    }
}



