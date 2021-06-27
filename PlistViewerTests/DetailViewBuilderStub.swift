//
//  DetailViewBuilderStub.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

import UIKit.UIViewController
@testable import PlistViewer

final class DetailViewBuilderStub: DetailViewBuilderProtocol {

	var detailFlow: DetailFlow
	var detailView: UIViewController
	var field: Model.Field?
	var index: Int?
	var model: Model?

	init(detailFlow: DetailFlow, detailView: UIViewController) {
		self.detailFlow = detailFlow
		self.detailView = detailView
	}

	func buildStack(field: Model.Field, with index: Int, in model: Model) -> (detailFlow: DetailFlow, detailView: UIViewController) {
		self.field = field
		self.index = index
		self.model = model
		return (detailFlow, detailView)
	}

}
