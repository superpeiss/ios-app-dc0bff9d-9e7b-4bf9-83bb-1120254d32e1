//
//  CloudFile.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Represents a file in cloud storage
struct CloudFile: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let path: String
    let size: Int64
    let modifiedDate: Date
    let serviceType: CloudServiceType
    let mimeType: String?
    let thumbnailURL: String?
    let downloadURL: String?
    let isFolder: Bool

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }

    var isImage: Bool {
        ["jpg", "jpeg", "png", "gif", "heic", "webp"].contains(fileExtension)
    }

    var isPDF: Bool {
        fileExtension == "pdf"
    }

    var isDocument: Bool {
        ["doc", "docx", "txt", "rtf", "pages"].contains(fileExtension)
    }

    var isVideo: Bool {
        ["mp4", "mov", "avi", "mkv", "m4v"].contains(fileExtension)
    }

    var isAudio: Bool {
        ["mp3", "wav", "aac", "m4a", "flac"].contains(fileExtension)
    }

    var canPreview: Bool {
        isImage || isPDF
    }

    /// Icon name for the file type (SF Symbols)
    var iconName: String {
        if isFolder {
            return "folder.fill"
        } else if isImage {
            return "photo.fill"
        } else if isPDF {
            return "doc.fill"
        } else if isDocument {
            return "doc.text.fill"
        } else if isVideo {
            return "video.fill"
        } else if isAudio {
            return "music.note"
        } else {
            return "doc"
        }
    }

    static func == (lhs: CloudFile, rhs: CloudFile) -> Bool {
        lhs.id == rhs.id && lhs.serviceType == rhs.serviceType
    }
}
