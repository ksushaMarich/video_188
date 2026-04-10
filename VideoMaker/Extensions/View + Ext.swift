import SwiftUI

extension View {
    func apply<T: View>(_ transform: (Self) -> T) -> T {
        transform(self)
    }
}


