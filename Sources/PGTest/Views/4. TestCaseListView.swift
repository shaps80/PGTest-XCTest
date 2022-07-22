import SwiftUI

internal struct TestCaseListView: View {
    let suite: TestSuite
    
    var body: some View {
        ForEach(suite.testCases) { testCase in
            TestCaseView(testCase: testCase)
        }
    }
}

struct TestCaseListView_Previews: PreviewProvider {
    static var previews: some View {
        TestResultsView()
    }
}
