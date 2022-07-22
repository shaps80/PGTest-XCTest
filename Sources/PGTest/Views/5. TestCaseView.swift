import SwiftUI

internal struct TestCaseView: View {
    @EnvironmentObject private var observer: PlaygroundObserver
    @State private var showInfo: Bool = false

    let testCase: TestCase
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    if testCase.isEnabled {
                        Button {
                            observer.run()
                        } label: {
                            Image(systemName: observer.state(for: testCase).isRunning ? "stop.circle" : "play.circle")
//                                .foregroundColor(observer.state.isRunning ? Color(uiColor: .secondaryLabel) : nil)
                                .foregroundColor(testCase.isEnabled ? .accentColor : Color(uiColor: .tertiaryLabel))
                        }
                        .buttonStyle(.plain)
                        .disabled(!testCase.isEnabled || observer.state(for: testCase).isRunning)
                        .opacity(observer.state(for: testCase).isRunning ? 0 : 1)
                        .overlay  {
                            if observer.state(for: testCase).isRunning {
                                ProgressView()
                                    .controlSize(.mini)
                            }
                        }
                        .disabled(observer.state.isRunning)
                    } else {
                        Button {
                            showInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.tint)
                        }
                        .sheet(isPresented: $showInfo) {
                            CopyCodeView(
                                title: "Missing TestCase",
                                message: "The test case has not been added to 'allTests'.",
                                code: testCase.code
                            )
                        }
                    }
                    
                    Text(testCase.name)
                        .foregroundColor(testCase.isEnabled ? .primary : Color(uiColor: .tertiaryLabel))
                }
                
                if case let .failed(error) = observer.state(for: testCase) {
                    TestErrorView(error: error)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }
            .font(.callout)
            .monospacedDigit()
            
            Spacer(minLength: 0)
            
            observer.state(for: testCase).systemImage
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 12))
        .padding(.vertical)
        .overlay(alignment: .top) { Divider() }
    }
}

struct TestCaseView_Previews: PreviewProvider {
    static var previews: some View {
        TestResultsView()
    }
}
