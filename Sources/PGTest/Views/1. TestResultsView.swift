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

    @StateObject private var observer: PlaygroundObserver = .init()
    @State private var console: PlaygroundConsoleObserver = .init()
    @State private var xcode: XcodeObserver = .init()

    @AppStorage("enableConsole") private var enableConsole: Bool = false
    @AppStorage("outputStyle") private var outputStyle: OutputStyle = .compact
    @State private var showCode: Bool = false

    public init() { }
    
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
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                showCode = true
                            } label: {
                                Label("Generate All Tests", systemImage: "curlybraces.square")
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
                        } label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showCode) {
                    CopyCodeView(
                        title: "Generate Code",
                        message: "The following code represents the required 'allTests' properties for all discovered suites.",
                        code: observer.code
                    )
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        if observer.numberOfTests == 0 {
                            Text("No tests found")
                        } else {
                            VStack(alignment: .leading) {
                                if observer.state.isRunning {
                                    Text("\(observer.passedCount + observer.failureCount) of \(observer.numberOfTests)")
                                        .font(.headline)
                                } else {
                                    Text("\(observer.numberOfTests) tests")
                                        .font(.headline)
                                }

                                Group {
                                    switch observer.state {
                                    case .undetermined, .skipped:
                                        Text("Tap play to run tests")
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
                    .background(.bar)
                    .cornerRadius(13)
                    .overlay {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(Color(uiColor: .quaternarySystemFill), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    .padding(.horizontal, 30)
                    .padding(.vertical)
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

struct TestResultsView_Previews: PreviewProvider {
    static var previews: some View {
        TestResultsView()
    }
}
