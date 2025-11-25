//
//  CloudServiceProtocol.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Error types for cloud operations
enum CloudServiceError: LocalizedError {
    case notAuthenticated
    case authenticationFailed(String)
    case networkError(Error)
    case fileNotFound
    case permissionDenied
    case operationFailed(String)
    case invalidPath
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please sign in."
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .fileNotFound:
            return "File or folder not found."
        case .permissionDenied:
            return "Permission denied."
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .invalidPath:
            return "Invalid file path."
        case .quotaExceeded:
            return "Storage quota exceeded."
        }
    }
}

/// Result type for file operations
enum FileOperationResult {
    case success(CloudFile)
    case failure(CloudServiceError)
}

/// Protocol defining cloud storage service operations
protocol CloudServiceProtocol {
    var serviceType: CloudServiceType { get }
    var isAuthenticated: Bool { get }

    /// Authenticate user with the cloud service
    func authenticate() async throws -> CloudAccount

    /// Sign out from the cloud service
    func signOut() async throws

    /// Get current account information
    func getAccountInfo() async throws -> CloudAccount

    /// List files and folders at the specified path
    /// - Parameter path: The path to list (empty string for root)
    /// - Returns: Array of CloudFile objects
    func listFiles(at path: String) async throws -> [CloudFile]

    /// Download file data
    /// - Parameter file: The file to download
    /// - Returns: File data
    func downloadFile(_ file: CloudFile) async throws -> Data

    /// Get temporary URL for file preview
    /// - Parameter file: The file to preview
    /// - Returns: Temporary URL
    func getPreviewURL(for file: CloudFile) async throws -> URL

    /// Create a new folder
    /// - Parameters:
    ///   - name: Name of the folder
    ///   - path: Parent path
    /// - Returns: Created folder
    func createFolder(name: String, at path: String) async throws -> CloudFile

    /// Delete a file or folder
    /// - Parameter file: The file to delete
    func deleteFile(_ file: CloudFile) async throws

    /// Rename a file or folder
    /// - Parameters:
    ///   - file: The file to rename
    ///   - newName: New name
    /// - Returns: Updated file
    func renameFile(_ file: CloudFile, to newName: String) async throws -> CloudFile

    /// Move a file or folder
    /// - Parameters:
    ///   - file: The file to move
    ///   - destinationPath: Destination path
    /// - Returns: Updated file
    func moveFile(_ file: CloudFile, to destinationPath: String) async throws -> CloudFile

    /// Copy a file or folder
    /// - Parameters:
    ///   - file: The file to copy
    ///   - destinationPath: Destination path
    /// - Returns: Copied file
    func copyFile(_ file: CloudFile, to destinationPath: String) async throws -> CloudFile

    /// Upload a file
    /// - Parameters:
    ///   - data: File data
    ///   - name: File name
    ///   - path: Destination path
    /// - Returns: Uploaded file
    func uploadFile(data: Data, name: String, to path: String) async throws -> CloudFile

    /// Search for files
    /// - Parameter query: Search query
    /// - Returns: Array of matching files
    func searchFiles(query: String) async throws -> [CloudFile]
}
