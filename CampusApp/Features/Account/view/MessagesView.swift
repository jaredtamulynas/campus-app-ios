//
//  MessagesView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import SwiftUI

struct MessagesView: View {
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                if !viewModel.messages.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                viewModel.markAllAsRead()
                            } label: {
                                Label("Mark All as Read", systemImage: "checkmark.circle")
                            }
                            .disabled(viewModel.unreadCount == 0)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Messages",
            systemImage: "tray",
            description: Text("You're all caught up!")
        )
    }

    private var messageList: some View {
        List {
            ForEach(viewModel.messages) { message in
                MessageRow(message: message)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { viewModel.deleteMessage(message) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if !message.isRead {
                            Button {
                                withAnimation { viewModel.markAsRead(message) }
                            } label: {
                                Label("Read", systemImage: "checkmark")
                            }
                            .tint(.blue)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Message Row

private struct MessageRow: View {
    let message: CampusMessage
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(message.title)
                    .font(.subheadline)
                    .fontWeight(message.isRead ? .regular : .semibold)
                Spacer()
                if !message.isRead {
                    Circle()
                        .fill(.accent)
                        .frame(width: 8, height: 8)
                        .accessibilityLabel("Unread")
                }
            }

            Text(message.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(message.relativeTime)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                if let url = message.actionURL {
                    Button { openURL(url) } label: {
                        Text("View")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isRead ? "" : "Unread: ")\(message.title)")
        .accessibilityHint(message.body)
    }
}

#Preview {
    MessagesView(viewModel: AccountViewModel())
}
