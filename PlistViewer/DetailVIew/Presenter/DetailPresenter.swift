//
//  DetailPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

final class DetailPresenter: DetailFlow {

	private var field: Model.Field
	private var model: Model
	var validateAndSaveModel: ((_ field: Model.Field, _ newModel: Model) throws -> Void)?
	weak var output: DetailPresenterOutput?

	init(field: Model.Field, model: Model) {
		self.field = field
		self.model = model
	}

}

protocol DetailFlow: AnyObject {
	var validateAndSaveModel: ((_ field: Model.Field, _ newModel: Model) throws -> Void)? { get set }
}

extension DetailPresenter: DetailViewControllerOutput {
	
}

protocol DetailPresenterOutput: AnyObject {

}
