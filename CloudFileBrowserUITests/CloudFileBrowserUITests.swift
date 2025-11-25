//
//  CloudFileBrowserUITests.swift
//  CloudFileBrowserUITests
//
//  Created by CloudFileBrowser
//

import XCTest

final class CloudFileBrowserUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchApp() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Cloud Files"].exists || app.staticTexts["No Connected Accounts"].exists)
    }
}
