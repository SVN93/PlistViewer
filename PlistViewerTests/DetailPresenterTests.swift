//
//  DetailPresenterTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 28.06.2021.
//

import XCTest
@testable import PlistViewer

final class DetailPresenterTests: XCTestCase {

	private var outputSpy: DetailPresenterOutputSpy!

	override func setUp() {
		super.setUp()
		outputSpy = .init()
	}

	override func tearDown() {
		outputSpy = nil
		super.tearDown()
	}

	func testValidateAndSaveValidField() {
		// Arrange
		let model = Model.mock
		let idx = 0
		let field = model.data[idx]
		let presenter = DetailPresenter(fieldIdx: idx, model: model)
		presenter.output = outputSpy

		// Act
		presenter.validateAndSaveIfValid(modifiedField: field)

		// Assert
		XCTAssertNil(outputSpy.lastInvalidIdentifiers)
		XCTAssertNil(outputSpy.lastShownError)
	}

	func testValidateAndSaveInvalidField() {
		// Arrange
		let model = Model.mock
		let idx = 0
		var field = model.data[idx]
		field[.name] = ""
		let presenter = DetailPresenter(fieldIdx: idx, model: model)
		presenter.output = outputSpy

		// Act
		presenter.validateAndSaveIfValid(modifiedField: field)

		// Assert
		XCTAssertEqual(outputSpy.lastInvalidIdentifiers, [.name])
		XCTAssertNil(outputSpy.lastShownError)
	}

}

extension DetailPresenterTests {

	final class DetailPresenterOutputSpy: DetailPresenterOutput {

		private(set) var lastShownError: Error?
		private(set) var lastInvalidIdentifiers: Set<Model.Identifier>?

		init() {}

		func show(error: Error) {
			lastShownError = error
		}

		func markInvalidValues(with identifiers: Set<Model.Identifier>) {
			lastInvalidIdentifiers = identifiers
		}

	}
}
