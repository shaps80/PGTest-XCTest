import SwiftUI

struct CopyCodeView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let message: String
    let code: String

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text(message)
                        Spacer(minLength: 0)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("```\(code)```")
                    }
                    .font(.footnote.monospaced())
                    .padding()
                    .background(Color(uiColor: .systemFill))
                    .cornerRadius(13)
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        UIPasteboard.general.string = code
                        dismiss()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                    }
                }
            }
        }
        .backport.presentationDetents([.medium, .large], selection: .constant(.medium))
        .navigationViewStyle(.stack)
        .accentColor(.brown)
    }
}
