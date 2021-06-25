//
//  ListPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import PlistService

final class ListPresenter: ListFlow {

	typealias ModelProvider = (() throws -> Model)
	private let modelProvider: ModelProvider
	private var model: Result<Model, Error>?
	var saveModel: ((_ newModel: Model) throws -> Void)?
	var showDetail: ((_ field: Model.Field, _ model: Model) -> Void)?
	weak var output: ListPresenterOutput?

	init(_ modelProvider: @escaping ModelProvider) {
		self.modelProvider = modelProvider
	}
}

protocol ListFlow: AnyObject {
	var saveModel: ((_ newModel: Model) throws -> Void)? { get set }
	var showDetail: ((_ field: Model.Field, _ model: Model) -> Void)? { get set }
}

extension ListPresenter: ListViewControllerOutput {

	func requestViewModel() {
		do {
			let model = try modelProvider()
			self.model = .success(model)
			output?.update(model: model, deletedRow: nil)
		} catch {
			self.model = .failure(error)
			output?.show(error: error)
		}
	}

	func delete(field: Model.Field, at row: Int) {
		do {
			guard
				case .success(var model) = model,
				model.data.indices.contains(row)
			else {
				throw ListPresenterError.internalInconsistency
			}

			model.data.remove(at: row)
			try saveModel?(model)
			self.model = .success(model)
			output?.update(model: model, deletedRow: row)
		} catch {
			self.model = .failure(error)
			output?.show(error: error)
		}
	}

	func showDetail(for field: Model.Field) {
		model?.mapIfSuccess { model in
			showDetail?(field, model)
		}
	}

}

protocol ListPresenterOutput: AnyObject {
	func update(model: Model, deletedRow: Int?)
	func show(error: Error)
}

extension ListPresenter {
	enum ListPresenterError: Swift.Error {
		case internalInconsistency
	}
}
