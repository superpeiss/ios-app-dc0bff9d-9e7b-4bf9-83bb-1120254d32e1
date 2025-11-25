//
//  AddAccountView.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(CloudServiceType.allCases) { serviceType in
                        Button {
                            Task {
                                await accountsViewModel.connectAccount(serviceType)
                                if !accountsViewModel.showError {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: serviceType.iconName)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(serviceType.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Connect your \(serviceType.rawValue) account")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .disabled(accountsViewModel.isLoading)
                    }
                } header: {
                    Text("Select a Service")
                } footer: {
                    Text("You can connect multiple accounts from the same service")
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if accountsViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)

                            Text("Connecting...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(30)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                    }
                }
            }
        }
    }
}
