import SwiftUI

struct TestSuiteView: View {
    @EnvironmentObject private var observer: PlaygroundObserver
    @State private var isExpanded: Bool = true
    @State private var showInfo: Bool = false

    let suite: TestSuite
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                TestCaseListView(suite: suite)
            }
        } label: {
            if suite.isEnabled {
                Button {
                    observer.run(selectedTests: [suite.name])
                } label: {
                    Image(systemName: suite.testCases.contains { observer.state(for: $0).isRunning } ? "stop.circle" : "play.circle")
                        .foregroundStyle(suite.isEnabled ? .brown : Color(uiColor: .tertiaryLabel))
                }
            } else {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.tint)
                }
                .sheet(isPresented: $showInfo) {
                    CopyCodeView(
                        title: "Missing TestSuite",
                        message: "The test suite does not appear to have a valid 'allTests'.",
                        code: suite.code
                    )
                }
            }
            
            Text(suite.name)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 12)

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(13)
        .padding(.horizontal)
        .buttonStyle(.plain)
    }
}
