//
//  ListPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import PlistService

final class ListPresenter: ListFlow {

	private let fileName: String
	private let plistService: PlistService
	private var lastUsedModel: Model?
	weak var output: ListPresenterOutput?
	var showDetail: ((_ field: Model.Field, _ model: Model) -> Void)?

	init(fileName: String, plistService: PlistService) {
		self.fileName = fileName
		self.plistService = plistService
	}

	func update(model: Model) {
		self.lastUsedModel = model
		output?.show(model: model)
	}

}

protocol ListFlow: AnyObject {
	var showDetail: ((_ field: Model.Field, _ model: Model) -> Void)? { get set }
	func update(model: Model)
}

extension ListPresenter: ListViewControllerOutput {

	func readPlist() {
		do {
			let model: Model = try plistService.readValue(from: fileName)
			try model.validateByScheme()
			lastUsedModel = model
			output?.show(model: model)
		} catch {
			print(error)
			output?.show(error: error)
		}
	}

	func delete(field: Model.Field) {
		guard
			var updatedModel = lastUsedModel,
			let idx = updatedModel.data.firstIndex(of: field)
		else { return }
		updatedModel.data.remove(at: idx)
		lastUsedModel = updatedModel
		output?.update(model: updatedModel, deletedRow: idx)
	}

	func showDetail(for field: Model.Field) {
		lastUsedModel.map { model in
			showDetail?(field, model)
		}
	}

}

protocol ListPresenterOutput: AnyObject {

	func show(model: Model)

	func update(model: Model, deletedRow: Int)

	func show(error: Error)

}
