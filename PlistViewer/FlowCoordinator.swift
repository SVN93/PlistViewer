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
	private let navigationControllerBuilder: (_ rootViewController: UIViewController) -> UINavigationController
	private weak var navigationController: UINavigationController?

	init(
		fileName: String = "Input",
		plistService: PlistService = PlistReaderService(bundlePlistName: "Input"),
		listViewBuilder: ListViewBuilderProtocol,
		detailViewBuilder: DetailViewBuilderProtocol,
		navigationControllerBuilder: @escaping (_ conntroller: UIViewController) -> UINavigationController
	) {
		self.fileName = fileName
		self.plistService = plistService
		self.listViewBuilder = listViewBuilder
		self.detailViewBuilder = detailViewBuilder
		self.navigationControllerBuilder = navigationControllerBuilder
	}

	private func startDetailFlow(for field: Model.Field, in model: Model) {
		let (detailFlow, detailView) = self.detailViewBuilder.buildStack(field: field, model: model)
		detailFlow.validateAndSaveModel = { [unowned self] field, model in
			try self.plistService.write(value: model, to: self.fileName)
			self.model = model
			self.listFlow?.update(field: field, for: model)
		}
		self.navigationController?.pushViewController(detailView, animated: true)
	}

	func start() -> UINavigationController {
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
		listFlow.showDetail = startDetailFlow(for:in:)
		let navigationController = navigationControllerBuilder(listView)
		self.navigationController = navigationController
		return navigationController
	}

}
