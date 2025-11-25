//
//  CloudFileBrowserTests.swift
//  CloudFileBrowserTests
//
//  Created by CloudFileBrowser
//

import XCTest
@testable import CloudFileBrowser

final class CloudFileBrowserTests: XCTestCase {

    func testCloudFileModel() {
        let file = CloudFile(
            id: "test123",
            name: "TestFile.pdf",
            path: "/Documents/TestFile.pdf",
            size: 1024,
            modifiedDate: Date(),
            serviceType: .dropbox,
            mimeType: "application/pdf",
            thumbnailURL: nil,
            downloadURL: nil,
            isFolder: false
        )

        XCTAssertEqual(file.name, "TestFile.pdf")
        XCTAssertTrue(file.isPDF)
        XCTAssertTrue(file.canPreview)
        XCTAssertFalse(file.isFolder)
    }

    func testCloudAccountModel() {
        let account = CloudAccount(
            id: "account123",
            serviceType: .dropbox,
            email: "test@example.com",
            displayName: "Test User",
            isConnected: true,
            connectedDate: Date(),
            lastSyncDate: Date(),
            totalSpace: 10_000_000_000,
            usedSpace: 5_000_000_000
        )

        XCTAssertEqual(account.email, "test@example.com")
        XCTAssertTrue(account.isConnected)
        XCTAssertEqual(account.usagePercentage, 0.5)
    }

    func testMockCloudService() async throws {
        let service = MockCloudService(serviceType: .dropbox)

        XCTAssertFalse(service.isAuthenticated)

        let account = try await service.authenticate()

        XCTAssertTrue(service.isAuthenticated)
        XCTAssertEqual(account.serviceType, .dropbox)

        let files = try await service.listFiles(at: "")

        XCTAssertFalse(files.isEmpty)
    }
}
