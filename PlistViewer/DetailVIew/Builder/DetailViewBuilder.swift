//
//  DetailViewBuilder.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit.UIViewController

final class DetailViewBuilder: DetailViewBuilderProtocol {

	init() {}

	func buildStack(
		field: Model.Field, with index: Int, in model: Model
	) -> (detailFlow: DetailFlow, detailView: UIViewController) {
		let presenter = DetailPresenter(fieldIdx: index, model: model)
		let detailViewController = DetailViewController(output: presenter, field: field, model: model)
		presenter.output = detailViewController
		return (presenter, detailViewController)
	}

}

protocol DetailViewBuilderProtocol {
	func buildStack(
		field: Model.Field, with index: Int, in model: Model
	) -> (detailFlow: DetailFlow, detailView: UIViewController)
}
