//
//  AccountsListView.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI

struct AccountsListView: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    @Binding var selectedAccount: CloudAccount?
    @State private var showAddAccount = false

    var body: some View {
        List(selection: $selectedAccount) {
            Section {
                ForEach(accountsViewModel.accounts) { account in
                    AccountRow(account: account)
                        .tag(account)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await accountsViewModel.disconnectAccount(account)
                                    if selectedAccount?.id == account.id {
                                        selectedAccount = nil
                                    }
                                }
                            } label: {
                                Label("Disconnect", systemImage: "trash")
                            }

                            Button {
                                Task {
                                    await accountsViewModel.refreshAccount(account)
                                }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                        }
                }
            } header: {
                Text("Connected Accounts")
            }
        }
        .navigationTitle("Cloud Files")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddAccount = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountView()
        }
        .alert("Error", isPresented: $accountsViewModel.showError) {
            Button("OK") {
                accountsViewModel.showError = false
            }
        } message: {
            if let error = accountsViewModel.errorMessage {
                Text(error)
            }
        }
    }
}

struct AccountRow: View {
    let account: CloudAccount

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: account.serviceType.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.headline)

                Text(account.email)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let usedSpace = account.formattedUsedSpace,
                   let totalSpace = account.formattedTotalSpace {
                    Text("\(usedSpace) of \(totalSpace) used")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if account.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}
