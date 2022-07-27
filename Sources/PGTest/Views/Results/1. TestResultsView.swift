import SwiftUI

public struct TestResultsView: View {
    enum OutputStyle: String, Identifiable, CaseIterable {
        var id: Self { self }
        case compact
        case verbose

        var systemImage: String {
            switch self {
            case .compact:
                return "rectangle.arrowtriangle.2.inward"
            case .verbose:
                return "rectangle.arrowtriangle.2.outward"
            }
        }
    }

    @StateObject private var observer: PlaygroundObserver
    @State private var console: PlaygroundConsoleObserver = .init()
    @State private var xcode: XcodeObserver = .init()

    @AppStorage("randomizeExecutionOrder") private var randomizeExecutionOrder: Bool = true
    @AppStorage("enableConsole") private var enableConsole: Bool = false
    @AppStorage("outputStyle") private var outputStyle: OutputStyle = .compact
    @State private var showCode: Bool = false

    public init(@TestCaseBuilder testCases: @escaping () -> [XCTestCase.Type]) {
        _observer = .init(wrappedValue: .init(testCases: testCases))
    }
    
    public var body: some View {
        NavigationView {
            TestSuiteListView()
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        switch observer.state {
                        case .running:
                            ProgressView()
                        default:
                            Button {
                                updateObservers(isEnabled: enableConsole, outputStyle: outputStyle)
                                observer.run()
                            } label: {
                                Label("Run", systemImage: "play.circle")
                                    .foregroundStyle(.tint)
                            }
                            .keyboardShortcut("U", modifiers: [.command, .shift])
                            .disabled(observer.disabledTestCount == observer.testCount)
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Toggle(isOn: $randomizeExecutionOrder) {
                                Label("Random Order", systemImage: "shuffle")
                            }

                            Divider()

                            Toggle(isOn: $enableConsole) { 
                                Label("Enable Console", systemImage: "terminal")
                            }

                            Picker(selection: $outputStyle) {
                                ForEach(OutputStyle.allCases) { style in
                                    Label(style.rawValue.capitalized, systemImage: style.systemImage)
                                        .tag(style)
                                }
                            } label: {
                                Label("Output Style", systemImage: "terminal.fill")
                            }
                            .pickerStyle(.menu)

                            Divider()

                            Button {
                                showCode = true
                            } label: {
                                Label("Generate All Tests", systemImage: "curlybraces.square")
                            }
                        } label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showCode) {
                    CopyCodeView(
                        title: "Generate Code",
                        message: "Copy the following code to a file in your project to enable these tests.",
                        code: observer.code
                    )
                }
                .safeAreaInset(edge: .bottom) {
                    FeedbackOverlay()
                }
                .navigationTitle("Test Results")
        }
        .accentColor(.brown)
        .environmentObject(observer)
    }

    private func updateObservers(isEnabled: Bool, outputStyle: OutputStyle) {
        XCTestObservationCenter.shared
            .removeTestObserver(xcode)
        XCTestObservationCenter.shared
            .removeTestObserver(console)

        if isEnabled {
            switch outputStyle {
            case .compact:
                XCTestObservationCenter.shared
                    .addTestObserver(console)
            case .verbose:
                XCTestObservationCenter.shared
                    .addTestObserver(xcode)
            }
        }
    }
}
