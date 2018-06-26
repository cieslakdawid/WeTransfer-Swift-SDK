//
//  AddFilesTests.swift
//  WeTransferTests
//
//  Created by Pim Coumans on 22/05/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import XCTest
@testable import WeTransfer

class AddFilesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
		TestConfiguration.configure(environment: .production)
    }
    
    override func tearDown() {
        super.tearDown()
		TestConfiguration.resetConfiguration()
    }

	func testAddingFilesToTransferModel() {
		let transfer = Transfer(name: "Test Transfer", description: nil)
		guard let file = TestConfiguration.fileModel else {
			XCTFail("Could not create file model")
			return
		}

		transfer.addFiles([file])
		XCTAssertTrue(transfer.files.contains(file))
		XCTAssertEqual(transfer.files.count, 1)

		transfer.addFiles([file])
		XCTAssertEqual(transfer.files.count, 1)
	}

	func testFileModel() {
		guard TestConfiguration.imageFileURL != nil else {
			XCTFail("Test image not found")
			return
		}

		guard let file = TestConfiguration.fileModel else {
			XCTFail("Could not create file model")
			return
		}

		XCTAssertNil(file.identifier)
		XCTAssertFalse(file.uploaded)
		XCTAssertNil(file.numberOfChunks)
		XCTAssertNil(file.multipartUploadIdentifier)
		XCTAssertEqual(file.filesize, 1200480, "File size not equal")
	}

	func testAddFilesRequest() {
		let transfer = Transfer(name: "Test Transfer", description: nil)

		guard let file = TestConfiguration.fileModel else {
			XCTFail("File not available")
			return
		}

		let addedFilesExpectation = expectation(description: "Files are added")

		WeTransfer.createTransfer(with: transfer, completion: { (result) in
			if case .failure(let error) = result {
				XCTFail("Create transfer failed: \(error)")
				return
			}

			WeTransfer.addFiles([file], to: transfer, completion: { (result) in
				if case .failure(let error) = result {
					XCTFail("Add files to transfer failed: \(error)")
					return
				}
				addedFilesExpectation.fulfill()
			})
		})

		waitForExpectations(timeout: 10) { _ in
			XCTAssertFalse(transfer.files.isEmpty)
			for file in transfer.files {
				XCTAssertNotNil(file.identifier)
				XCTAssertFalse(file.isUploaded)
			}
		}
	}
}
