//
//  DetailViewControllerTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 28.06.2021.
//

import XCTest
@testable import PlistViewer

final class DetailViewControllerTests: XCTestCase {

	func testValidateAndSaveIfValid() {
		// Arrange
		let outputSpy = DetailViewControllerOutputSpy()
		let model = Model.mock
		let field = model.data[0]
		let detailViewController = DetailViewController(output: outputSpy, field: field, model: model)

		// Act
		detailViewController.loadViewIfNeeded()
		guard
			let rightBarButtonItem = detailViewController.navigationItem.rightBarButtonItem,
			let action = rightBarButtonItem.action
		else {
			return XCTFail("No rightBarButtonItem!")
		}
		XCTAssertTrue(UIApplication.shared.sendAction(action, to: rightBarButtonItem.target, from: nil, for: nil))

		// Arrange
		XCTAssertEqual(outputSpy.lastModifiedField, field)
	}

}

extension DetailViewControllerTests {

	final class DetailViewControllerOutputSpy: DetailViewControllerOutput {

		private(set) var lastModifiedField: Model.Field?

		init() {}

		func validateAndSaveIfValid(modifiedField: Model.Field) {
			lastModifiedField = modifiedField
		}
		
	}
}
