//
//  SimpleTransferTests.swift
//  WeTransferTests
//
//  Created by Pim Coumans on 22/05/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import XCTest
@testable import WeTransfer

class AuthorizationTests: XCTestCase {

	override func setUp() {
		super.setUp()
		TestConfiguration.configure(environment: .production)
	}

	override func tearDown() {
		super.tearDown()
		TestConfiguration.resetConfiguration()
	}

	func testUnauthorized() {
		do {
			_ = try WeTransfer.client.createRequest(.createTransfer())
		} catch {
			XCTAssertEqual(error.localizedDescription, WeTransfer.Error.notAuthorized.localizedDescription)
		}
	}

	func testAuthorization() {
		let authorizedExpectation = expectation(description: "Authorization should succeed")
		WeTransfer.authorize { (result) in
			if case .failure(let error) = result {
				XCTFail("Authorization failed: \(error)")
			}
			authorizedExpectation.fulfill()
		}

		waitForExpectations(timeout: 10) { _ in }
		}
	}

}
