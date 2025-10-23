import SwiftUI
import MessageUI
import UniformTypeIdentifiers

struct MailView: UIViewControllerRepresentable {
    var subject: String
    var body: String
    var recipients: [String]?

    /// Images to attach (e.g. from PhotosPicker -> [UIImage])
    var images: [UIImage] = []

    /// Optional: arbitrary attachments
    var attachments: [(data: Data, mimeType: String, fileName: String)] = []

    /// Caller's result
    var resultHandler: ((MFMailComposeResult) -> Void)? = nil

    /// If Mail isn't configured, present a Share Sheet fallback with the images
    var fallbackShareSheetTitle: String = "Share Booking"

    @Environment(\.dismiss) private var dismiss

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) { self.parent = parent }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            parent.resultHandler?(result)
            controller.dismiss(animated: true)
            parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIViewController {
        // If Mail is configured, use MFMailComposeViewController
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = context.coordinator
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            if let recipients { mail.setToRecipients(recipients) }

            // Attach UIImages (downscale & convert)
            for (idx, img) in images.enumerated() {
                let processed = downscale(img: img, maxDimension: 1920) // ~1080–2K long edge
                if let data = processed.jpegData(compressionQuality: 0.8) {
                    mail.addAttachmentData(data, mimeType: "image/jpeg", fileName: "photo\(idx + 1).jpg")
                    debugLog("Attached photo\(idx+1).jpg (\(bytesString(data.count)))")
                } else if let data = processed.pngData() {
                    mail.addAttachmentData(data, mimeType: "image/png", fileName: "photo\(idx + 1).png")
                    debugLog("Attached photo\(idx+1).png (\(bytesString(data.count)))")
                } else {
                    debugLog("⚠️ Failed to convert image \(idx + 1) to JPEG/PNG")
                }
            }

            for item in attachments {
                mail.addAttachmentData(item.data, mimeType: item.mimeType, fileName: item.fileName)
                debugLog("Attached \(item.fileName) (\(bytesString(item.data.count)))")
            }

            return mail
        }

        // Fallback: Share Sheet (includes images as real attachments)
        let activityItems: [Any] = {
            var arr: [Any] = []
            let composedText = buildFallbackText()
            arr.append(composedText)
            // Add images directly — most share targets (including Mail if chosen) will include them
            arr.append(contentsOf: images)
            // Add arbitrary attachments via temporary files
            for item in attachments {
                let url = writeTempFile(data: item.data, fileName: item.fileName)
                if let url { arr.append(url) }
            }
            return arr
        }()

        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.title = fallbackShareSheetTitle
        // Wrap in a hosting VC so we conform to UIViewControllerRepresentable
        return UINavigationController(rootViewController: UIViewController()).then {
            $0.viewControllers.first?.present(activityVC, animated: false)
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    // MARK: - Helpers

    /// Downscale to keep email sizes reasonable
    private func downscale(img: UIImage, maxDimension: CGFloat) -> UIImage {
        let w = img.size.width, h = img.size.height
        let maxSide = max(w, h)
        guard maxSide > maxDimension else { return img }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in img.draw(in: CGRect(origin: .zero, size: newSize)) }
    }

    private func bytesString(_ n: Int) -> String {
        let kb = Double(n) / 1024.0
        let mb = kb / 1024.0
        return mb >= 1 ? String(format: "%.2f MB", mb) : String(format: "%.0f KB", kb)
    }

    private func debugLog(_ s: String) {
        #if DEBUG
        print("[MailView] \(s)")
        #endif
    }

    /// Compose a plain text body for fallback share sheet
    private func buildFallbackText() -> String {
        var lines: [String] = []
        if !subject.isEmpty { lines.append(subject) }
        if !body.isEmpty { lines.append(body) }
        if let recipients, !recipients.isEmpty {
            lines.append("To: \(recipients.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n\n")
    }

    /// Write temp file for attachments when using share sheet
    private func writeTempFile(data: Data, fileName: String) -> URL? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do { try data.write(to: url); return url } catch { debugLog("⚠️ Could not write \(fileName): \(error)"); return nil }
    }
}

// Tiny helper so we can present the Activity VC cleanly
private extension UINavigationController {
    func then(_ apply: (UINavigationController) -> Void) -> UINavigationController { apply(self); return self }
}

