//
//  DetailPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

final class DetailPresenter: DetailFlow {

	private var model: Model
	private let fieldIdx: Int
	var saveModel: SaveModel?
	weak var output: DetailPresenterOutput?

	init(fieldIdx: Int, model: Model) {
		self.model = model
		self.fieldIdx = fieldIdx
	}

}

protocol DetailFlow: AnyObject {
	typealias SaveModel = ((_ field: Model.Field, _ newModel: Model) throws -> Void)
	var saveModel: SaveModel? { get set }
}

extension DetailPresenter: DetailViewControllerOutput {

	private func save(_ field: Model.Field) throws {
		var modifiedModel = model
		modifiedModel.data[fieldIdx] = field
		try saveModel?(field, modifiedModel)
		self.model = modifiedModel
	}

	func validateAndSaveIfValid(modifiedField: Model.Field) {
		do {
			let validationErrors = try modifiedField.validateAllValues(by: model.scheme)
			if validationErrors.isEmpty {
				try save(modifiedField)
			} else {
				var wrongIds: Set<Model.Identifier> = []
				validationErrors.forEach { wrongIds.insert($0.identifier) }
				output?.markInvalidValues(with: wrongIds)
			}
		} catch {
			output?.show(error: error)
		}
	}

	func validate(field: Model.Field) throws -> Set<Model.Identifier> {
		let validationErrors = try field.validateAllValues(by: model.scheme)
		var wrongIds: Set<Model.Identifier> = []
		validationErrors.forEach { wrongIds.insert($0.identifier) }
		return wrongIds
	}

}

protocol DetailPresenterOutput: AnyObject {
	func show(error: Error)
	func markInvalidValues(with identifiers: Set<Model.Identifier>)
}
