//
//  CloudServiceType.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Represents the different cloud storage providers supported by the app
enum CloudServiceType: String, Codable, CaseIterable, Identifiable {
    case dropbox = "Dropbox"
    case googleDrive = "Google Drive"
    case oneDrive = "OneDrive"
    case iCloud = "iCloud Drive"

    var id: String { rawValue }

    /// Icon name for the service (SF Symbols)
    var iconName: String {
        switch self {
        case .dropbox:
            return "folder.fill.badge.gearshape"
        case .googleDrive:
            return "externaldrive.fill"
        case .oneDrive:
            return "cloud.fill"
        case .iCloud:
            return "icloud.fill"
        }
    }

    /// Primary color for the service
    var colorHex: String {
        switch self {
        case .dropbox:
            return "#0061FF"
        case .googleDrive:
            return "#4285F4"
        case .oneDrive:
            return "#0078D4"
        case .iCloud:
            return "#3B99FC"
        }
    }
}
