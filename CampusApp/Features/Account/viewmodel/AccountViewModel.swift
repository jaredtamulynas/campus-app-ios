//
//  AccountViewModel.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/14/25.
//

import Foundation

@Observable
final class AccountViewModel {
    private let service: AccountServiceProtocol
    
    var accountData: AccountData?
    var messages: [CampusMessage] = []
    var state: LoadState = .loading
    
    init(service: AccountServiceProtocol = AccountService()) {
        self.service = service
    }
    
    @MainActor
    func loadAccountData() async {
        state = .loading
        
        do {
            let data = try await service.fetchAccountData()
            self.accountData = data
            // Load sample messages for now (will be replaced with FCM)
            self.messages = CampusMessage.samples
            state = .loaded
        } catch {
            state = .error(error)
        }
    }
    
    var sections: [AccountSection] {
        accountData?.sections ?? []
    }
    
    var unreadCount: Int {
        messages.filter { !$0.isRead }.count
    }
    
    func markAsRead(_ message: CampusMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isRead = true
        }
    }
    
    func markAllAsRead() {
        for index in messages.indices {
            messages[index].isRead = true
        }
    }
    
    func deleteMessage(_ message: CampusMessage) {
        messages.removeAll { $0.id == message.id }
    }
}
