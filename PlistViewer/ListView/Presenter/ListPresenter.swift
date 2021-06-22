//
//  ListPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import PlistService

final class ListPresenter {

	private let fileName: String
	private let plistService: PlistService
	private var lastUsedModel: Model?
	weak var output: ListPresenterOutput?

	init(fileName: String, plistService: PlistService) {
		self.fileName = fileName
		self.plistService = plistService
	}

}

extension ListPresenter: ListViewControllerOutput {

	func delete(field: Model.Field) {
		guard
			var updatedModel = lastUsedModel,
			let idx = updatedModel.data.firstIndex(of: field)
		else { return }
		updatedModel.data.remove(at: idx)
		lastUsedModel = updatedModel
		output?.update(model: updatedModel, deletedRow: idx)
	}

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

}

protocol ListPresenterOutput: AnyObject {

	func show(model: Model)

	func update(model: Model, deletedRow: Int)

	func show(error: Error)

}
