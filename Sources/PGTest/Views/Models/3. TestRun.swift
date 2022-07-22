import SwiftUI

internal struct TestRun: Identifiable, Codable {
    enum State: Codable, Equatable {
        case undetermined
        case running
        case skipped
        case passed
        case failed(TestError)
        
        var isFailure: Bool {
            if case .failed = self { return true }
            return false
        }

        var isSkipped: Bool {
            if case .skipped = self { return true }
            return false
        }
    }
    
    var id: String
    var state: State = .undetermined
}

extension TestRun.State {
    var isRunning: Bool {
        if case .running = self {
            return true
        } else { 
            return false
        }
    }
    
    @ViewBuilder
    var systemImage: some View {
        switch self {
        case .undetermined:
            Image(systemName: "circle")
                .opacity(0)
        case .skipped:
            Image(systemName: "arrow.turn.down.right")
                .foregroundStyle(.tertiary)
        case .running:
            Image(systemName: "circle")
                .opacity(0)
        case .failed:
            Image(systemName: "xmark.circle")
                .foregroundColor(.red)
        case .passed:
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
        }
    }
}
