import SwiftUI

struct FeedbackOverlay: View {
    @EnvironmentObject private var observer: PlaygroundObserver

    var body: some View {
        HStack {
            if observer.testCount == 0 {
                Text("No tests found")
            } else {
                VStack(alignment: .leading) {
                    if observer.state.isRunning {
                        Text("\(observer.passedCount + observer.failureCount) of \(observer.testCount)")
                            .font(.headline)
                    } else {
                        Text("\(observer.testCount) tests")
                            .foregroundColor(.primary)
                            .font(.headline)
                    }

                    Group {
                        switch observer.state {
                        case .undetermined, .skipped:
                            if observer.testCount == observer.disabledTestCount {
                                Text("Tap ") + Text(Image(systemName: "ellipsis.circle")) + Text(" to generate test code")
                            } else {
                                Text("Tap play to run tests")
                            }
                        case .failed:
                            Text("\(observer.formatTimeInterval(observer.runtime))s (\(observer.failureCount) failed)")
                        case .passed:
                            Text("\(observer.formatTimeInterval(observer.runtime))s")
                        case .running:
                            Text("Running...")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)

            if observer.state.isRunning {
                ProgressView()
            } else {
                observer.state.systemImage
                    .imageScale(.large)
            }
        }
        .padding()
        .background(.bar, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .padding(.horizontal, 30)
        .padding(.vertical)
    }
}
