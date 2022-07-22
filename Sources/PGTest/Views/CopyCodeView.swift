import SwiftUI

struct CopyCodeView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let message: String
    let code: String

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text(message)
                            Spacer(minLength: 0)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            Text("`\(code)`")
                        }
                        .font(.footnote.monospaced())
                        .padding()
                        .background(Color(uiColor: .systemFill))
                        .cornerRadius(13)
                    }
                    .padding([.horizontal, .bottom])
                    .navigationTitle(title)
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        UIPasteboard.general.string = code
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Copy", systemImage: "doc.on.doc")
                            Spacer()
                        }
                    }
                    .padding(.vertical, 5)
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .background(.thickMaterial, ignoresSafeAreaEdges: .all)
                    .ignoresSafeArea()
                }
            }
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                }
            }
        }
        .backport.presentationDetents([.medium, .large], selection: .constant(.medium))
    }
}
