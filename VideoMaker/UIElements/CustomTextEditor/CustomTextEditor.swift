
import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var onFocusChange: ((Bool) -> Void)? = nil

    func makeUIView(context: Context) -> UITextView {
        let view = ZeroInsetTextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.font = CabinetGroteskUIFont.regular.of(size: 17)
        view.textColor = .introSubtitle
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onFocusChange: onFocusChange)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var onFocusChange: ((Bool) -> Void)?

        init(text: Binding<String>, onFocusChange: ((Bool) -> Void)?) {
            self.text = text
            self.onFocusChange = onFocusChange
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            onFocusChange?(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            onFocusChange?(false)
        }
    }
}

