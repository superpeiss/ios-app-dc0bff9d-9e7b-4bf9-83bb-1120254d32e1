//
//  CloudServiceManager.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Manages all cloud service instances and accounts
@MainActor
class CloudServiceManager: ObservableObject {
    static let shared = CloudServiceManager()

    @Published private(set) var accounts: [CloudAccount] = []
    @Published private(set) var isLoading = false

    private var services: [CloudServiceType: CloudServiceProtocol] = [:]

    private init() {
        setupServices()
        loadAccounts()
    }

    private func setupServices() {
        // Initialize mock services for all types
        // In production, replace with actual service implementations
        for serviceType in CloudServiceType.allCases {
            services[serviceType] = MockCloudService(serviceType: serviceType)
        }
    }

    func getService(for type: CloudServiceType) -> CloudServiceProtocol? {
        return services[type]
    }

    func getService(for account: CloudAccount) -> CloudServiceProtocol? {
        return services[account.serviceType]
    }

    func connectAccount(_ serviceType: CloudServiceType) async throws -> CloudAccount {
        guard let service = services[serviceType] else {
            throw CloudServiceError.operationFailed("Service not available")
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let account = try await service.authenticate()

            // Check if account already exists
            if let index = accounts.firstIndex(where: { $0.serviceType == serviceType && $0.email == account.email }) {
                accounts[index] = account
            } else {
                accounts.append(account)
            }

            saveAccounts()
            return account
        } catch {
            throw CloudServiceError.authenticationFailed(error.localizedDescription)
        }
    }

    func disconnectAccount(_ account: CloudAccount) async throws {
        guard let service = services[account.serviceType] else {
            throw CloudServiceError.operationFailed("Service not available")
        }

        isLoading = true
        defer { isLoading = false }

        try await service.signOut()

        accounts.removeAll { $0.id == account.id }
        saveAccounts()
    }

    func refreshAccount(_ account: CloudAccount) async throws -> CloudAccount {
        guard let service = services[account.serviceType] else {
            throw CloudServiceError.operationFailed("Service not available")
        }

        let updatedAccount = try await service.getAccountInfo()

        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = updatedAccount
            saveAccounts()
        }

        return updatedAccount
    }

    // MARK: - Persistence

    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: "CloudAccounts"),
           let decoded = try? JSONDecoder().decode([CloudAccount].self, from: data) {
            accounts = decoded
        }
    }

    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: "CloudAccounts")
        }
    }
}
