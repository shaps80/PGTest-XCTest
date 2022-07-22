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
                .environmentObject(observer)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
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
                    
                    ToolbarItem(placement: .principal) {
                        runtime
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            updateObservers(isEnabled: enableConsole, outputStyle: outputStyle)
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
