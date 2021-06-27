//
//  ListViewBuilderStub.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

import UIKit.UIViewController
@testable import PlistViewer

final class ListViewBuilderStub: ListViewBuilderProtocol {

	var listFlow: ListFlow
	var listView: UIViewController
	var modelProvider: ListPresenter.ModelProvider?

	init(listFlow: ListFlow, listView: UIViewController) {
		self.listFlow = listFlow
		self.listView = listView
	}

	func buildStack(modelProvider: @escaping ListPresenter.ModelProvider) -> (listFlow: ListFlow, listView: UIViewController) {
		self.modelProvider = modelProvider
		return (listFlow, listView)
	}
	
}
