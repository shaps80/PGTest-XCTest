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
    //                        print("Run \(testCase.name) only")
                        } label: {
                            Image(systemName: observer.state(for: testCase) == .running ? "stop.circle" : "play.circle")
                                .foregroundStyle(testCase.isEnabled ? .brown : Color(uiColor: .tertiaryLabel))
                        }
                        .buttonStyle(.plain)
                        .disabled(!testCase.isEnabled)
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
