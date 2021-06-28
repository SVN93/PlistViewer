//
//  ListViewControllerTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 28.06.2021.
//

import XCTest
@testable import PlistViewer

final class ListViewControllerTests: XCTestCase {

	private var outputSpy: ListViewControllerOutputSpy!

	override func setUp() {
		super.setUp()
		outputSpy = .init()
	}

	override func tearDown() {
		outputSpy = nil
		super.tearDown()
	}

	func testViewDidLoad() {
		// Arrange
		let listViewController = ListViewController(output: outputSpy)

		// Act
		listViewController.loadViewIfNeeded()

		// Assert
		XCTAssertTrue(outputSpy.didRequestViewModel)
	}

	func testDelete() {
		// Arrange
		let listViewController = ListViewController(output: outputSpy)
		let viewModel = Model.mock

		// Act
		listViewController.loadViewIfNeeded()
		listViewController.update(model: viewModel, deletedRow: nil)
		guard
			let cell = listViewController.tableView(
				listViewController.tableView, cellForRowAt: .init(row: 0, section: 0)
			) as? ListViewCell
		else {
			return XCTFail("Cannot cast to ListViewCell!")
		}
		cell.viewModel.map { $0.deleteAction?($0) }

		// Assert
		XCTAssertTrue(outputSpy.didRequestViewModel)
		XCTAssertNotNil(outputSpy.lastFieldToDelete)
	}

	func testShowDetail() {
		// Arrange
		let listViewController = ListViewController(output: outputSpy)
		let viewModel = Model.mock

		// Act
		listViewController.loadViewIfNeeded()
		listViewController.update(model: viewModel, deletedRow: nil)
		listViewController.tableView(listViewController.tableView, didSelectRowAt: .init(row: 0, section: 0))

		// Assert
		XCTAssertTrue(outputSpy.didRequestViewModel)
		XCTAssertNotNil(outputSpy.showDetailForField)
	}

}

extension ListViewControllerTests {

	final class ListViewControllerOutputSpy: ListViewControllerOutput {

		private(set) var didRequestViewModel = false
		private(set) var lastFieldToDelete: Model.Field?
		private(set) var showDetailForField: Model.Field?

		init() {}

		func requestViewModel() {
			didRequestViewModel = true
		}

		func delete(field: Model.Field, at row: Int) {
			lastFieldToDelete = field
		}

		func showDetail(for field: Model.Field, with index: Int) {
			showDetailForField = field
		}

	}

}
