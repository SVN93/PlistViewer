//
//  ListPresenterTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

import XCTest
@testable import PlistViewer

final class ListPresenterTests: XCTestCase {

	private var outputSpy: ListPresenterOutputSpy!

	override func setUp() {
		super.setUp()
		outputSpy = .init()
	}

	override func tearDown() {
		outputSpy = nil
		super.tearDown()
	}

	private func presenterWithModel(_ model: Model = .mock) -> ListPresenter {
		let model: Model = .mock
		let presenter = ListPresenter { completion in
			completion(.success(model))
		}
		return presenter
	}

	func testRequestViewModel() {
		// Arrange
		let model: Model = .mock
		let presenter = presenterWithModel(model)
		presenter.output = outputSpy

		// Act
		presenter.requestViewModel()

		// Assert
		XCTAssertEqual(outputSpy.lastUpdatedModel, model)
		XCTAssertNil(outputSpy.lastDeletedRow)
		XCTAssertNil(outputSpy.lastShownError)
	}

	func testDeleteField() {
		// Arrange
		var model: Model = .mock
		let presenter = presenterWithModel(model)
		presenter.output = outputSpy
		let idx = 0
		let field = model.data[idx]
		model.data.remove(at: idx)

		// Act
		presenter.requestViewModel()
		presenter.delete(field: field, at: idx)

		// Assert
		XCTAssertEqual(outputSpy.lastUpdatedModel, model)
		XCTAssertEqual(outputSpy.lastDeletedRow, idx)
		XCTAssertNil(outputSpy.lastShownError)
	}

	func testUpdateField() {
		// Arrange
		var model: Model = .mock
		let presenter = presenterWithModel(model)
		presenter.output = outputSpy
		let idx = 0
		let field = model.data[idx]
		model.data.remove(at: idx)

		// Act
		presenter.requestViewModel()
		presenter.update(field: field, at: idx, for: model)

		// Assert
		XCTAssertEqual(outputSpy.lastUpdatedModel, model)
		XCTAssertEqual(outputSpy.lastUpdateRow, idx)
		XCTAssertNil(outputSpy.lastShownError)
	}
}

extension ListPresenterTests {

	final class ListPresenterOutputSpy: ListPresenterOutput {

		private(set) var lastUpdatedModel: Model?
		private(set) var lastDeletedRow: Int?
		private(set) var lastUpdateRow: Int?
		private(set) var lastShownError: Error?

		init() {}

		func update(model: Model, deletedRow: Int?) {
			lastUpdatedModel = model
			lastDeletedRow = deletedRow
		}

		func update(model: Model, updateRow: Int) {
			lastUpdatedModel = model
			lastUpdateRow = updateRow
		}

		func show(error: Error) {
			lastShownError = error
		}

	}

}
