//
//  CloudAccount.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import Foundation

/// Represents a connected cloud storage account
struct CloudAccount: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let serviceType: CloudServiceType
    let email: String
    let displayName: String
    var isConnected: Bool
    let connectedDate: Date

    var lastSyncDate: Date?
    var totalSpace: Int64?
    var usedSpace: Int64?

    var availableSpace: Int64? {
        guard let total = totalSpace, let used = usedSpace else { return nil }
        return total - used
    }

    var usagePercentage: Double? {
        guard let total = totalSpace, total > 0, let used = usedSpace else { return nil }
        return Double(used) / Double(total)
    }

    var formattedUsedSpace: String? {
        guard let used = usedSpace else { return nil }
        return ByteCountFormatter.string(fromByteCount: used, countStyle: .file)
    }

    var formattedTotalSpace: String? {
        guard let total = totalSpace else { return nil }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    static func == (lhs: CloudAccount, rhs: CloudAccount) -> Bool {
        lhs.id == rhs.id && lhs.serviceType == rhs.serviceType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(serviceType)
    }
}
