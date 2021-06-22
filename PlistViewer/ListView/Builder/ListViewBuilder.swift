//
//  ListViewBuilder.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import UIKit
import PlistService

enum ListViewBuilder {

	static func buildStack(plistService: PlistService = PlistReaderService(bundlePlistName: "Input")) -> UIViewController {
		let presenter = ListPresenter(fileName: "Input", plistService: plistService)
		let listViewController = ListViewController(output: presenter)
		presenter.output = listViewController
		return listViewController
	}

}
