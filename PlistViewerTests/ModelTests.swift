//
//  ModelTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 28.06.2021.
//

import XCTest
@testable import PlistViewer

final class ModelTests: XCTestCase {

	func testValidation() {
		// Arrange
		let model = Model.mock
		var field = model.data[0]
		field[.name] = ""
		field[.birthdate] = "Foo"

		do {
			// Act
			let invalidIDs = try field.validateAllValues(by: model.scheme)

			// Assert
			XCTAssertTrue(invalidIDs.contains(.valueShouldntBeEmpty(.name)))
			XCTAssertTrue(invalidIDs.contains(.wrongType(.birthdate)))
		} catch {
			// Assert
			XCTFail(error.localizedDescription)
		}
	}

}
