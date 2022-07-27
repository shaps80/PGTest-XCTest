import SwiftUI

extension Animation {
    static var reveal: Self {
        .interactiveSpring(response: 0.2, dampingFraction: 0.8, blendDuration: 0.2)
    }
}
