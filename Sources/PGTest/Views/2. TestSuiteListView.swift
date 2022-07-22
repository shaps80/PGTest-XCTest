import SwiftUI

internal struct TestSuiteListView: View {
    @EnvironmentObject private var observer: PlaygroundObserver
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(observer.suites) { suite in
                    TestSuiteView(suite: suite)
                }
            }
        }
        .overlay { 
            if observer.suites.isEmpty {
                Text("No tests found.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
