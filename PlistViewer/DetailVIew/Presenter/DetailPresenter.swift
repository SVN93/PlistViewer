//
//  DetailPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

final class DetailPresenter: DetailFlow {

	private var field: Model.Field
	private var model: Model
	var saveAction: ((_ field: Model.Field) -> Void)?
	weak var output: DetailPresenterOutput?

	init(field: Model.Field, model: Model) {
		self.field = field
		self.model = model
	}

}

protocol DetailFlow: AnyObject {
	var saveAction: ((_ field: Model.Field) -> Void)? { get set }
}

extension DetailPresenter: DetailViewControllerOutput {
	
}

protocol DetailPresenterOutput: AnyObject {

}
