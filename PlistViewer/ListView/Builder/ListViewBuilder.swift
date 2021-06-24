//
//  ListViewBuilder.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import UIKit.UIViewController
import PlistService

final class ListViewBuilder: ListViewBuilderProtocol {

	private let fileName: String
	private let plistService: PlistService

	init(fileName: String = "Input", plistService: PlistService = PlistReaderService(bundlePlistName: "Input")) {
		self.fileName = fileName
		self.plistService = plistService
	}

	func buildStack() -> (listFlow: ListFlow, listView: UIViewController) {
		let presenter = ListPresenter(fileName: fileName, plistService: plistService)
		let listViewController = ListViewController(output: presenter)
		presenter.output = listViewController
		return (presenter, listViewController)
	}

}

protocol ListViewBuilderProtocol {
	func buildStack() -> (listFlow: ListFlow, listView: UIViewController)
}
