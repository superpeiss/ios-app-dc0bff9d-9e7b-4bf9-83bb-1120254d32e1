//
//  AccountsViewModel.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation
import SwiftUI

/// ViewModel for managing cloud accounts
@MainActor
class AccountsViewModel: ObservableObject {
    @Published var accounts: [CloudAccount] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let serviceManager = CloudServiceManager.shared

    init() {
        loadAccounts()
    }

    func loadAccounts() {
        accounts = serviceManager.accounts
    }

    func connectAccount(_ serviceType: CloudServiceType) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await serviceManager.connectAccount(serviceType)
            accounts = serviceManager.accounts
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func disconnectAccount(_ account: CloudAccount) async {
        isLoading = true
        errorMessage = nil

        do {
            try await serviceManager.disconnectAccount(account)
            accounts = serviceManager.accounts
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func refreshAccount(_ account: CloudAccount) async {
        do {
            let updated = try await serviceManager.refreshAccount(account)
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
