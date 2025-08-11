import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    var subject: String
    var body: String
    var recipients: [String]?
    
    /// ✅ New: pass result back to the caller
    var resultHandler: ((MFMailComposeResult) -> Void)? = nil

    @Environment(\.dismiss) var dismiss

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            /// ✅ Notify parent about the result
            parent.resultHandler?(result)
            
            controller.dismiss(animated: true)
            parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: false)
        if let recipients = recipients {
            mail.setToRecipients(recipients)
        }
        mail.mailComposeDelegate = context.coordinator
        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

