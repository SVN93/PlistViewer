//
//  FlowCoordinatorTests.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

import XCTest
@testable import PlistViewer

final class FlowCoordinatorTests: XCTestCase {

	private let modelMock = Model.mock
	private let fileName = "TestInput"
	private var plistServiceSpy: PlistServiceSpy<PlistViewer.Model>!
	private var listFlowSpy: ListFlowSpy!
	private var detailFlowSpy: DetailFlowSpy!
	private var listViewBuilderStub: ListViewBuilderStub!
	private var detailViewBuilderStub: DetailViewBuilderStub!
	private var navigationControllerSpy: NavigationControllerSpy!
	private var flowCoordinator: FlowCoordinator!

	override func setUp() {
		plistServiceSpy = PlistServiceSpy(model: modelMock)
		listFlowSpy = .init()
		listViewBuilderStub = .init(listFlow: listFlowSpy, listView: UIViewController())
		detailFlowSpy = .init()
		detailViewBuilderStub = .init(detailFlow: detailFlowSpy, detailView: UIViewController())
		flowCoordinator = FlowCoordinator(
			fileName: fileName,
			plistService: plistServiceSpy,
			listViewBuilder: listViewBuilderStub,
			detailViewBuilder: detailViewBuilderStub,
			navigationControllerBuilder: {
				self.navigationControllerSpy = NavigationControllerSpy(rootViewController: $0)
				return self.navigationControllerSpy
			}
		)
		super.setUp()
	}

	override func tearDown() {
		flowCoordinator = nil
		plistServiceSpy = nil
		listFlowSpy = nil
		listViewBuilderStub = nil
		detailFlowSpy = nil
		detailViewBuilderStub = nil
		navigationControllerSpy = nil
		super.tearDown()
	}

	@discardableResult
	private func start() -> UIViewController {
		guard let flowCoordinator = flowCoordinator else {
			XCTFail("Неправильное использование \(#function)")
			return UIViewController()
		}
		return flowCoordinator.start()
	}

	func testStart() {
		// Arrange & Act
		let viewController = start()

		// Assert
		XCTAssertTrue(viewController == navigationControllerSpy)
		XCTAssertEqual(navigationControllerSpy.rootViewController, listViewBuilderStub.listView)
		XCTAssertNotNil(listViewBuilderStub.modelProvider)
		XCTAssertNotNil(listFlowSpy.saveModel)
		XCTAssertNotNil(listFlowSpy.showDetail)
	}

	func testModelProvider() {
		// Arrange
		start()
		let expectation = self.expectation(description: "modelProvider")

		// Act
		listViewBuilderStub.modelProvider? { [unowned self] result in
			expectation.fulfill()

			// Assert
			switch result {
			case .success(let model):
				XCTAssertEqual(model, self.modelMock)
				XCTAssertEqual(self.plistServiceSpy.readFileName, self.fileName)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}

		waitForExpectations(timeout: 0.1) { error in
			error.map { XCTFail($0.localizedDescription) }
		}
	}

	func testListFlowSaveModel() {
		// Arrange
		start()

		do {
			// Act
			try listFlowSpy.saveModel?(modelMock)

			// Assert
			XCTAssertEqual(plistServiceSpy.writtenValue, modelMock)
			XCTAssertEqual(plistServiceSpy.writeFileName, fileName)
		} catch {
			// Assert
			XCTFail(error.localizedDescription)
		}
	}

	func testShowDetail() {
		// Arrange
		start()
		let idx = 0
		let field = modelMock.data[idx]

		// Act
		listFlowSpy.showDetail?(field, idx, modelMock)

		// Assert
		XCTAssertEqual(detailViewBuilderStub.field, field)
		XCTAssertEqual(detailViewBuilderStub.index, idx)
		XCTAssertEqual(detailViewBuilderStub.model, modelMock)
		XCTAssertNotNil(detailFlowSpy.saveModel)
		XCTAssertEqual(navigationControllerSpy.lastPushedVC, detailViewBuilderStub.detailView)
	}

	func testDetailSave() {
		// Arrange
		start()
		let idx = 0
		let field = modelMock.data[idx]

		// Act
		listFlowSpy.showDetail?(field, idx, modelMock)

		do {
			try detailFlowSpy.saveModel?(field, modelMock)

			// Assert
			XCTAssertEqual(plistServiceSpy.writtenValue, modelMock)
			XCTAssertEqual(plistServiceSpy.writeFileName, fileName)
			XCTAssertEqual(listFlowSpy.updatedField, field)
			XCTAssertEqual(listFlowSpy.updatedIndex, idx)
			XCTAssertEqual(listFlowSpy.updatedModel, modelMock)
			XCTAssertEqual(navigationControllerSpy.lastPopedVC, detailViewBuilderStub.detailView)
		} catch {
			// Assert
			XCTFail(error.localizedDescription)
		}
	}

}

final class NavigationControllerSpy: UINavigationController {

	var rootViewController: UIViewController
	var lastPushedVC: UIViewController?
	var lastPopedVC: UIViewController?

	override init(rootViewController: UIViewController) {
		self.rootViewController = rootViewController
		super.init(rootViewController: rootViewController)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		lastPushedVC = viewController
		super.pushViewController(viewController, animated: false)
	}

	override func popViewController(animated: Bool) -> UIViewController? {
		lastPopedVC = super.popViewController(animated: false)
		return lastPopedVC
	}

}
