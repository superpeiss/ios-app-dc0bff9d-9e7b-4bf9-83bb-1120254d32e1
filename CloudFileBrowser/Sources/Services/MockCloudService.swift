//
//  MockCloudService.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Mock implementation of CloudServiceProtocol for testing and development
class MockCloudService: CloudServiceProtocol {
    let serviceType: CloudServiceType
    private(set) var isAuthenticated: Bool = false
    private var mockFiles: [String: [CloudFile]] = [:]
    private var currentAccount: CloudAccount?

    init(serviceType: CloudServiceType) {
        self.serviceType = serviceType
        setupMockData()
    }

    private func setupMockData() {
        // Root folder files
        mockFiles[""] = [
            CloudFile(
                id: "folder1",
                name: "Documents",
                path: "/Documents",
                size: 0,
                modifiedDate: Date().addingTimeInterval(-86400 * 30),
                serviceType: serviceType,
                mimeType: nil,
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: true
            ),
            CloudFile(
                id: "folder2",
                name: "Photos",
                path: "/Photos",
                size: 0,
                modifiedDate: Date().addingTimeInterval(-86400 * 15),
                serviceType: serviceType,
                mimeType: nil,
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: true
            ),
            CloudFile(
                id: "file1",
                name: "Resume.pdf",
                path: "/Resume.pdf",
                size: 245000,
                modifiedDate: Date().addingTimeInterval(-86400 * 7),
                serviceType: serviceType,
                mimeType: "application/pdf",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            )
        ]

        // Documents folder
        mockFiles["/Documents"] = [
            CloudFile(
                id: "doc1",
                name: "Project Proposal.pdf",
                path: "/Documents/Project Proposal.pdf",
                size: 1245000,
                modifiedDate: Date().addingTimeInterval(-86400 * 5),
                serviceType: serviceType,
                mimeType: "application/pdf",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            ),
            CloudFile(
                id: "doc2",
                name: "Meeting Notes.txt",
                path: "/Documents/Meeting Notes.txt",
                size: 12400,
                modifiedDate: Date().addingTimeInterval(-86400 * 2),
                serviceType: serviceType,
                mimeType: "text/plain",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            ),
            CloudFile(
                id: "doc3",
                name: "Contract.pdf",
                path: "/Documents/Contract.pdf",
                size: 856000,
                modifiedDate: Date().addingTimeInterval(-86400 * 10),
                serviceType: serviceType,
                mimeType: "application/pdf",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            )
        ]

        // Photos folder
        mockFiles["/Photos"] = [
            CloudFile(
                id: "photo1",
                name: "Vacation.jpg",
                path: "/Photos/Vacation.jpg",
                size: 2456000,
                modifiedDate: Date().addingTimeInterval(-86400 * 20),
                serviceType: serviceType,
                mimeType: "image/jpeg",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            ),
            CloudFile(
                id: "photo2",
                name: "Family.png",
                path: "/Photos/Family.png",
                size: 3245000,
                modifiedDate: Date().addingTimeInterval(-86400 * 25),
                serviceType: serviceType,
                mimeType: "image/png",
                thumbnailURL: nil,
                downloadURL: nil,
                isFolder: false
            )
        ]
    }

    func authenticate() async throws -> CloudAccount {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let account = CloudAccount(
            id: UUID().uuidString,
            serviceType: serviceType,
            email: "user@example.com",
            displayName: "Demo User",
            isConnected: true,
            connectedDate: Date(),
            lastSyncDate: Date(),
            totalSpace: 15_000_000_000,
            usedSpace: 5_234_567_890
        )

        self.currentAccount = account
        self.isAuthenticated = true
        return account
    }

    func signOut() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        isAuthenticated = false
        currentAccount = nil
    }

    func getAccountInfo() async throws -> CloudAccount {
        guard let account = currentAccount, isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }
        return account
    }

    func listFiles(at path: String) async throws -> [CloudFile] {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return mockFiles[path] ?? []
    }

    func downloadFile(_ file: CloudFile) async throws -> Data {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        // Simulate download delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Return mock data
        if file.isPDF {
            // Mock PDF data
            return Data("Mock PDF content for \(file.name)".utf8)
        } else if file.isImage {
            // Mock image data
            return Data("Mock image data for \(file.name)".utf8)
        } else {
            return Data("Mock file content for \(file.name)".utf8)
        }
    }

    func getPreviewURL(for file: CloudFile) async throws -> URL {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        // Return a mock URL
        return URL(string: "https://example.com/preview/\(file.id)")!
    }

    func createFolder(name: String, at path: String) async throws -> CloudFile {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let newFolder = CloudFile(
            id: UUID().uuidString,
            name: name,
            path: "\(path)/\(name)",
            size: 0,
            modifiedDate: Date(),
            serviceType: serviceType,
            mimeType: nil,
            thumbnailURL: nil,
            downloadURL: nil,
            isFolder: true
        )

        mockFiles[path, default: []].append(newFolder)
        mockFiles[newFolder.path] = []

        return newFolder
    }

    func deleteFile(_ file: CloudFile) async throws {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        // Remove from mock data
        let parentPath = (file.path as NSString).deletingLastPathComponent
        mockFiles[parentPath]?.removeAll { $0.id == file.id }
    }

    func renameFile(_ file: CloudFile, to newName: String) async throws -> CloudFile {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let parentPath = (file.path as NSString).deletingLastPathComponent
        let newPath = "\(parentPath)/\(newName)"

        let renamedFile = CloudFile(
            id: file.id,
            name: newName,
            path: newPath,
            size: file.size,
            modifiedDate: Date(),
            serviceType: file.serviceType,
            mimeType: file.mimeType,
            thumbnailURL: file.thumbnailURL,
            downloadURL: file.downloadURL,
            isFolder: file.isFolder
        )

        // Update in mock data
        if var files = mockFiles[parentPath] {
            if let index = files.firstIndex(where: { $0.id == file.id }) {
                files[index] = renamedFile
                mockFiles[parentPath] = files
            }
        }

        return renamedFile
    }

    func moveFile(_ file: CloudFile, to destinationPath: String) async throws -> CloudFile {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 800_000_000)

        let newPath = "\(destinationPath)/\(file.name)"
        let movedFile = CloudFile(
            id: file.id,
            name: file.name,
            path: newPath,
            size: file.size,
            modifiedDate: Date(),
            serviceType: file.serviceType,
            mimeType: file.mimeType,
            thumbnailURL: file.thumbnailURL,
            downloadURL: file.downloadURL,
            isFolder: file.isFolder
        )

        // Remove from old location
        let oldParent = (file.path as NSString).deletingLastPathComponent
        mockFiles[oldParent]?.removeAll { $0.id == file.id }

        // Add to new location
        mockFiles[destinationPath, default: []].append(movedFile)

        return movedFile
    }

    func copyFile(_ file: CloudFile, to destinationPath: String) async throws -> CloudFile {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 800_000_000)

        let newPath = "\(destinationPath)/\(file.name)"
        let copiedFile = CloudFile(
            id: UUID().uuidString,
            name: file.name,
            path: newPath,
            size: file.size,
            modifiedDate: Date(),
            serviceType: file.serviceType,
            mimeType: file.mimeType,
            thumbnailURL: file.thumbnailURL,
            downloadURL: file.downloadURL,
            isFolder: file.isFolder
        )

        mockFiles[destinationPath, default: []].append(copiedFile)

        return copiedFile
    }

    func uploadFile(data: Data, name: String, to path: String) async throws -> CloudFile {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 1_500_000_000)

        let uploadedFile = CloudFile(
            id: UUID().uuidString,
            name: name,
            path: "\(path)/\(name)",
            size: Int64(data.count),
            modifiedDate: Date(),
            serviceType: serviceType,
            mimeType: nil,
            thumbnailURL: nil,
            downloadURL: nil,
            isFolder: false
        )

        mockFiles[path, default: []].append(uploadedFile)

        return uploadedFile
    }

    func searchFiles(query: String) async throws -> [CloudFile] {
        guard isAuthenticated else {
            throw CloudServiceError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 700_000_000)

        var results: [CloudFile] = []
        for (_, files) in mockFiles {
            results.append(contentsOf: files.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            })
        }

        return results
    }
}
