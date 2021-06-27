//
//  FlowCoordinator.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

import UIKit
import PlistService

final class FlowCoordinator {

	private let fileName: String
	private let plistService: PlistService
	private var model: Model?
	private var listFlow: ListFlow?
	private let listViewBuilder: ListViewBuilderProtocol
	private let detailViewBuilder: DetailViewBuilderProtocol
	typealias NavigationControllerBuilder = (_ rootViewController: UIViewController) -> UINavigationController
	private let navigationControllerBuilder: NavigationControllerBuilder
	private weak var navigationController: UINavigationController?

	init(
		fileName: String = "Input",
		plistService: PlistService = PlistReaderService(bundlePlistName: "Input"),
		listViewBuilder: ListViewBuilderProtocol = ListViewBuilder(),
		detailViewBuilder: DetailViewBuilderProtocol = DetailViewBuilder(),
		navigationControllerBuilder: @escaping NavigationControllerBuilder = UINavigationController.init(rootViewController:)
	) {
		self.fileName = fileName
		self.plistService = plistService
		self.listViewBuilder = listViewBuilder
		self.detailViewBuilder = detailViewBuilder
		self.navigationControllerBuilder = navigationControllerBuilder
	}

	private func startDetailFlow(for field: Model.Field, with index: Int, in model: Model) {
		let (detailFlow, detailView) = self.detailViewBuilder.buildStack(field: field, with: index, in: model)
		detailFlow.saveModel = { [unowned self] field, model in
			try self.plistService.write(value: model, to: self.fileName)
			self.model = model
			self.listFlow?.update(field: field, at: index, for: model)
			self.navigationController?.popViewController(animated: true)
		}
		self.navigationController?.pushViewController(detailView, animated: true)
	}

	func start() -> UIViewController {
		let (listFlow, listView) = listViewBuilder.buildStack(modelProvider: { [unowned self] in
			let model: Model = try self.plistService.readValue(from: self.fileName)
			try model.validateByScheme()
			self.model = model
			return model
		})
		self.listFlow = listFlow
		listFlow.saveModel = { [unowned self] modelToSave in
			try self.plistService.write(value: modelToSave, to: self.fileName)
		}
		listFlow.showDetail = startDetailFlow(for:with:in:)
		let navigationController = navigationControllerBuilder(listView)
		self.navigationController = navigationController
		return navigationController
	}

}
