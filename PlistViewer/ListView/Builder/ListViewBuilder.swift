//
//  ListViewBuilder.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import UIKit.UIViewController
import PlistService

final class ListViewBuilder: ListViewBuilderProtocol {

	init() {}

	func buildStack(modelProvider: @escaping ListPresenter.ModelProvider) -> (listFlow: ListFlow, listView: UIViewController) {
		let presenter = ListPresenter(modelProvider)
		let listViewController = ListViewController(output: presenter)
		presenter.output = listViewController
		return (presenter, listViewController)
	}

}

protocol ListViewBuilderProtocol {
	func buildStack(
		modelProvider: @escaping ListPresenter.ModelProvider
	) -> (listFlow: ListFlow, listView: UIViewController)
}
