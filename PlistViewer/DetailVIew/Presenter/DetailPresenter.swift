//
//  DetailPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

final class DetailPresenter: DetailFlow {

	private var field: Model.Field
	private var model: Model
	var saveModel: ((_ field: Model.Field, _ newModel: Model) throws -> Void)?
	weak var output: DetailPresenterOutput?

	init(field: Model.Field, model: Model) {
		self.field = field
		self.model = model
	}

}

protocol DetailFlow: AnyObject {
	var saveModel: ((_ field: Model.Field, _ newModel: Model) throws -> Void)? { get set }
}

extension DetailPresenter: DetailViewControllerOutput {

	func validate(field: Model.Field) throws -> Set<Model.Identifier> {
		var wrongIds: Set<Model.Identifier> = []
		try field.forEach { id, value in
			guard let config = model.scheme.config(for: id) else { return }
			let isValid = try value.validate(with: config.type)
			if !isValid { wrongIds.insert(id) }
		}
		return wrongIds
	}

}

protocol DetailPresenterOutput: AnyObject {

}
