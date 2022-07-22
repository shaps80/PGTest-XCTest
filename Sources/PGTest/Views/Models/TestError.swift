import SwiftUI

internal struct TestErrorView: View {
    let error: TestError
    
    var body: some View {
        Text(error.localizedDescription)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

internal struct TestError: LocalizedError, Codable, Equatable {
    #warning("Ideally add line no, file, etc")
    var errorDescription: String?
}

extension TestError {
    init(_ error: TestError) {
        self.errorDescription = error.localizedDescription
    }
}
