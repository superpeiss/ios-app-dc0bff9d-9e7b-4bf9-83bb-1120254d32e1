//
//  CloudFileBrowserApp.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI

@main
struct CloudFileBrowserApp: App {
    @StateObject private var accountsViewModel = AccountsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accountsViewModel)
        }
    }
}
