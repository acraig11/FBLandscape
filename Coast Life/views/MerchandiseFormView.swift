import SwiftUI
import MessageUI

struct MerchandiseFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var organization = ""
    @State private var email = ""
    @State private var message = ""

    @State private var showMailView = false
    @State private var lastMailResult: MFMailComposeResult? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Info")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)

                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)

                    TextField("Organization (optional)", text: $organization)
                        .autocapitalization(.words)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                Section(header: Text("Message / Type of Merchandise Requested")) {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                        .padding(.vertical, 4)
                }

                Section {
                    Button("Submit Request") {
                        showMailView = true
                    }
                    .disabled(name.isEmpty || phone.isEmpty || email.isEmpty)
                }
            }
            .navigationTitle("Request Art & Toys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showMailView, onDismiss: handleMailDismiss) {
                MailView(
                    subject: "Art & Toys Request",
                    body: formattedEmailBody(),
                    recipients: ["coastlifellc@gmail.com"],
                    resultHandler: { result in
                        lastMailResult = result
                    }
                )
            }
        }
    }

    private func formattedEmailBody() -> String {
        """
        Merchandise Request:

        Name: \(name)
        Phone: \(phone)
        Organization: \(organization)
        Email: \(email)

        Message / Requested Items:
        \(message)
        """
    }

    private func handleMailDismiss() {
        if lastMailResult == .sent {
            dismiss() // close the form if email was sent
        }

        lastMailResult = nil
    }
}

