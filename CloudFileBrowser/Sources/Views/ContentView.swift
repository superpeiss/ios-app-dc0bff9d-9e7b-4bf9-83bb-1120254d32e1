//
//  ContentView.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    @State private var selectedAccount: CloudAccount?

    var body: some View {
        NavigationView {
            if accountsViewModel.accounts.isEmpty {
                AccountsEmptyView()
            } else {
                AccountsListView(selectedAccount: $selectedAccount)
            }

            if let account = selectedAccount {
                FileBrowserView(account: account)
            } else {
                PlaceholderView()
            }
        }
        .navigationViewStyle(.columns)
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("Select an account to browse files")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct AccountsEmptyView: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    @State private var showAddAccount = false

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "cloud.slash.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            VStack(spacing: 12) {
                Text("No Connected Accounts")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Connect your cloud storage accounts to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                showAddAccount = true
            } label: {
                Label("Connect Account", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .sheet(isPresented: $showAddAccount) {
            AddAccountView()
        }
        .navigationTitle("Cloud Files")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AccountsViewModel())
    }
}
