//
//  FlowCoordinator.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

import UIKit
import PlistService

final class FlowCoordinator {

	private let listViewBuilder: ListViewBuilderProtocol
	private let detailViewBuilder: DetailViewBuilderProtocol
	private let navigationControllerBuilder: (_ conntroller: UIViewController) -> UINavigationController
	private weak var navigationController: UINavigationController?

	init(
		listViewBuilder: ListViewBuilderProtocol,
		detailViewBuilder: DetailViewBuilderProtocol,
		navigationControllerBuilder: @escaping (_ conntroller: UIViewController) -> UINavigationController
	) {
		self.listViewBuilder = listViewBuilder
		self.detailViewBuilder = detailViewBuilder
		self.navigationControllerBuilder = navigationControllerBuilder
	}

	func start() -> UINavigationController {
		let (listFlow, listView) = listViewBuilder.buildStack()
		listFlow.showDetail = { [weak self] field, model in
			guard let self = self else { return }
			let (detailFlow, detailView) = self.detailViewBuilder.buildStack(field: field, model: model)
			detailFlow.saveAction = { field in
				print(field)
			}
			self.navigationController?.pushViewController(detailView, animated: true)
		}
		let navigationController = navigationControllerBuilder(listView)
		self.navigationController = navigationController
		return navigationController
	}

}
