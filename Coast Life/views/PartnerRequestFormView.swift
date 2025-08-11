import SwiftUI
import MessageUI

struct PartnerRequestFormView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var organization = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var message = ""
    @State private var submitted = false

    @State private var showMailComposer = false
    @State private var showMailError = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("Name", text: $name)
                    TextField("Organization/Business", text: $organization)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone#", text: $phone)
                       
                }

                Section(header: Text("Message")) {
                    TextEditor(text: $message)
                        .frame(height: 120)
                }

                if submitted {
                    Section {
                        Text("✅ Request submitted! Thank you.")
                            .foregroundColor(.green)
                    }
                }

                Section {
                    Button("Submit Request") {
                        submit()
                    }
                    .disabled(name.isEmpty || email.isEmpty || message.isEmpty)
                }
            }
            .navigationTitle("Partner Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showMailComposer) {
            MailView(
                subject: "New Partner Request",
                body: """
                Name: \(name)
                Organization: \(organization)
                Email: \(email)
                Phone: \(phone)
                Message:
                \(message)
                """,
                recipients: ["coastlifellc@gmail.com"]
            )
        }
        .alert("Unable to Send Email", isPresented: $showMailError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up an email account in the Mail app to send this request.")
        }
    }

    private func submit() {
        submitted = true

        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            showMailError = true
        }

        print("📤 Submitted: \(name), \(organization), \(email),\(phone), \(message)")
    }
}

