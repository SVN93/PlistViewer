//
//  DetailViewBuilder.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit.UIViewController

final class DetailViewBuilder: DetailViewBuilderProtocol {

	private var field: Model.Field?
	private var model: Model?

	func buildStack(
		field: Model.Field, model: Model
	) -> (detailFlow: DetailFlow, detailView: UIViewController) {
		self.field = field
		self.model = model
		let presenter = DetailPresenter(field: field, model: model)
		let detailViewController = DetailViewController(
			output: presenter,
			field: field,
			model: model
		)
		presenter.output = detailViewController
		return (presenter, detailViewController)
	}

}

protocol DetailViewBuilderProtocol {
	func buildStack(
		field: Model.Field, model: Model
	) -> (detailFlow: DetailFlow, detailView: UIViewController)
}
