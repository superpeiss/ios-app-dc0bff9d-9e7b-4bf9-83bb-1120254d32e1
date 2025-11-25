//
//  FileBrowserView.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI

struct FileBrowserView: View {
    let account: CloudAccount
    @StateObject private var viewModel = FileBrowserViewModel()
    @State private var showCreateFolder = false
    @State private var newFolderName = ""

    var body: some View {
        Group {
            if viewModel.searchQuery.isEmpty {
                fileListView
            } else {
                searchResultsView
            }
        }
        .navigationTitle(account.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(account.displayName)
                        .font(.headline)
                    Text(viewModel.displayPath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }

                    Button {
                        showCreateFolder = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search files")
        .onChange(of: viewModel.searchQuery) { _ in
            if !viewModel.searchQuery.isEmpty {
                Task {
                    await viewModel.search()
                }
            } else {
                viewModel.clearSearch()
            }
        }
        .onAppear {
            viewModel.setAccount(account)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("New Folder", isPresented: $showCreateFolder) {
            TextField("Folder Name", text: $newFolderName)
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
            Button("Create") {
                Task {
                    await viewModel.createFolder(name: newFolderName)
                    newFolderName = ""
                }
            }
        } message: {
            Text("Enter a name for the new folder")
        }
        .sheet(isPresented: $viewModel.showPreview) {
            if let file = viewModel.previewFile, let data = viewModel.previewData {
                FilePreviewView(file: file, data: data)
            }
        }
    }

    private var fileListView: some View {
        Group {
            if viewModel.isLoading && viewModel.files.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.files.isEmpty {
                emptyStateView
            } else {
                List {
                    if viewModel.canGoBack {
                        Button {
                            viewModel.navigateBack()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }

                    ForEach(viewModel.files) { file in
                        FileRow(file: file) {
                            handleFileTap(file)
                        }
                        .contextMenu {
                            fileContextMenu(for: file)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }

    private var searchResultsView: some View {
        Group {
            if viewModel.isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No results found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.searchResults) { file in
                        FileRow(file: file) {
                            handleFileTap(file)
                        }
                        .contextMenu {
                            fileContextMenu(for: file)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("This folder is empty")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func handleFileTap(_ file: CloudFile) {
        if file.isFolder {
            viewModel.navigateToFolder(file)
        } else if file.canPreview {
            Task {
                await viewModel.loadPreview(for: file)
            }
        }
    }

    @ViewBuilder
    private func fileContextMenu(for file: CloudFile) -> some View {
        if file.canPreview {
            Button {
                Task {
                    await viewModel.loadPreview(for: file)
                }
            } label: {
                Label("Preview", systemImage: "eye")
            }
        }

        Button {
            viewModel.selectedFile = file
            viewModel.newFileName = file.name
            viewModel.showRenameAlert = true
        } label: {
            Label("Rename", systemImage: "pencil")
        }

        Button {
            viewModel.selectedFile = file
            viewModel.showDeleteAlert = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .alert("Delete File", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let file = viewModel.selectedFile {
                    Task {
                        await viewModel.deleteFile(file)
                    }
                }
            }
        } message: {
            if let file = viewModel.selectedFile {
                Text("Are you sure you want to delete '\(file.name)'?")
            }
        }

        .alert("Rename", isPresented: $viewModel.showRenameAlert) {
            TextField("New Name", text: $viewModel.newFileName)
            Button("Cancel", role: .cancel) {}
            Button("Rename") {
                if let file = viewModel.selectedFile {
                    Task {
                        await viewModel.renameFile(file, to: viewModel.newFileName)
                    }
                }
            }
        } message: {
            Text("Enter a new name for this file")
        }
    }
}

struct FileRow: View {
    let file: CloudFile
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: file.iconName)
                    .font(.title2)
                    .foregroundColor(file.isFolder ? .accentColor : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        if !file.isFolder {
                            Text(file.formattedSize)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(file.modifiedDate, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if file.isFolder {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
