//
//  FileBrowserViewModel.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation
import SwiftUI

/// ViewModel for browsing and managing files
@MainActor
class FileBrowserViewModel: ObservableObject {
    @Published var files: [CloudFile] = []
    @Published var currentPath: String = ""
    @Published var currentAccount: CloudAccount?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var searchResults: [CloudFile] = []

    // File operation states
    @Published var showMoveSheet = false
    @Published var showCopySheet = false
    @Published var showRenameAlert = false
    @Published var showDeleteAlert = false
    @Published var selectedFile: CloudFile?
    @Published var newFileName = ""

    // Preview
    @Published var previewFile: CloudFile?
    @Published var previewData: Data?
    @Published var showPreview = false

    private let serviceManager = CloudServiceManager.shared
    private var navigationStack: [String] = [""]

    var canGoBack: Bool {
        navigationStack.count > 1
    }

    var displayPath: String {
        currentPath.isEmpty ? "Root" : currentPath
    }

    func setAccount(_ account: CloudAccount) {
        currentAccount = account
        currentPath = ""
        navigationStack = [""]
        Task {
            await loadFiles()
        }
    }

    func loadFiles() async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account) else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            files = try await service.listFiles(at: currentPath)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            files = []
        }

        isLoading = false
    }

    func navigateToFolder(_ file: CloudFile) {
        guard file.isFolder else { return }
        navigationStack.append(currentPath)
        currentPath = file.path
        Task {
            await loadFiles()
        }
    }

    func navigateBack() {
        guard canGoBack else { return }
        currentPath = navigationStack.removeLast()
        Task {
            await loadFiles()
        }
    }

    func refresh() async {
        await loadFiles()
    }

    // MARK: - File Operations

    func deleteFile(_ file: CloudFile) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account) else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await service.deleteFile(file)
            await loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func renameFile(_ file: CloudFile, to newName: String) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account),
              !newName.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.renameFile(file, to: newName)
            await loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func moveFile(_ file: CloudFile, to destinationPath: String) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account) else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.moveFile(file, to: destinationPath)
            await loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func copyFile(_ file: CloudFile, to destinationPath: String) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account) else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.copyFile(file, to: destinationPath)
            await loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func createFolder(name: String) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account),
              !name.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.createFolder(name: name, at: currentPath)
            await loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    // MARK: - Preview

    func loadPreview(for file: CloudFile) async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account),
              file.canPreview else {
            return
        }

        isLoading = true
        previewFile = file

        do {
            previewData = try await service.downloadFile(file)
            showPreview = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    // MARK: - Search

    func search() async {
        guard let account = currentAccount,
              let service = serviceManager.getService(for: account),
              !searchQuery.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true

        do {
            searchResults = try await service.searchFiles(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            searchResults = []
        }

        isSearching = false
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
    }
}
