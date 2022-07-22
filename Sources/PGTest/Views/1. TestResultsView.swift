import SwiftUI

public struct TestResultsView: View {
    @StateObject private var observer: PlaygroundObserver = .init()
    @State private var console: PlaygroundConsoleObserver = .init()

    @AppStorage("enableConsole") private var enableConsole: Bool = false
    @State private var showCode: Bool = false

    public init() { }
    
    public var body: some View {
        NavigationView {
            TestSuiteListView()
                .environmentObject(observer)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Menu {
                            Toggle(isOn: $enableConsole) { 
                                Label("Enable Console", systemImage: "terminal")
                            }

                            Divider()

                            Button {
                                showCode = true
                            } label: {
                                Label("Generate All Tests", systemImage: "ellipsis.curlybraces")
                            }
                        } label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        runtime
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            if enableConsole {
                                XCTestObservationCenter.shared
                                    .addTestObserver(console)
                            } else {
                                XCTestObservationCenter.shared
                                    .removeTestObserver(console)
                            }

                            observer.run()
                        } label: {
                            Label("Run", systemImage: observer.isRunning ? "stop.circle" : "play.circle")
                                .foregroundColor(observer.isRunning ? .orange : nil)
                        }
                        .disabled(observer.isRunning)
                        .keyboardShortcut("U", modifiers: [.command, .shift])
                    }
                }
                .sheet(isPresented: $showCode) {
                    CopyCodeView(
                        title: "Generate Code",
                        message: "The following code represents the required 'allTests' properties for all discovered suites.",
                        code: observer.code
                    )
                }
        }
        .tint(.brown)
    }
    
    @ViewBuilder
    private var runtime: some View {
        if observer.runtime == 0 {
            Text("Tests")
        } else {
            Text("\(observer.formatTimeInterval(observer.runtime))s")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
