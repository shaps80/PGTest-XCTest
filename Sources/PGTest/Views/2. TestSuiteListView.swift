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
                    .foregroundStyle(.tertiary)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct TestSuiteListView_Previews: PreviewProvider {
    static var previews: some View {
        TestResultsView()
    }
}
