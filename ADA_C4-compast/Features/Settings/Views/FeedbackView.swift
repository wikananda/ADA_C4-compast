//
//  FeedbackView.swift
//  ADA_C4-compast
//
//  Settings Module - Feedback View
//

import SwiftUI

/// View for collecting user feedback.
struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var showSubmitAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("We'd love to hear your feedback!")
                .font(.headline)
                .padding(.horizontal)

            feedbackEditor

            submitButton

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSubmitAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your feedback has been submitted.")
        }
    }

    // MARK: - Subviews

    private var feedbackEditor: some View {
        TextEditor(text: $feedbackText)
            .frame(minHeight: 150)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
    }

    private var submitButton: some View {
        Button(action: submitFeedback) {
            Text("Submit Feedback")
                .frame(maxWidth: .infinity)
                .padding()
                .background(feedbackText.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(feedbackText.isEmpty)
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func submitFeedback() {
        guard !feedbackText.isEmpty else { return }
        // Submit feedback logic would go here
        showSubmitAlert = true
    }
}

#Preview {
    NavigationView {
        FeedbackView()
    }
}
