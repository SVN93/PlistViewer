//
//  ListPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import PlistService

final class ListPresenter: ListFlow {

	typealias CompletionHandler = (_ result: Result<Model, Error>) -> Void
	typealias ModelProvider = ((_ completion: @escaping CompletionHandler) -> Void)
	private let modelProvider: ModelProvider
	private var model: Result<Model, Error>?
	var saveModel: SaveModel?
	var showDetail: ShowDetail?
	weak var output: ListPresenterOutput?

	init(_ modelProvider: @escaping ModelProvider) {
		self.modelProvider = modelProvider
	}

	func update(field: Model.Field, at index: Int, for model: Model) {
		self.model = .success(model)
		output?.update(model: model, updateRow: index)
	}

}

protocol ListFlow: AnyObject {
	typealias SaveModel = ((_ newModel: Model) throws -> Void)
	typealias ShowDetail = ((_ field: Model.Field, _ atIndex: Int, _ inModel: Model) -> Void)
	var saveModel: SaveModel? { get set }
	var showDetail: ShowDetail? { get set }
	func update(field: Model.Field, at index: Int, for model: Model)
}

extension ListPresenter: ListViewControllerOutput {

	func requestViewModel() {
		modelProvider { [unowned self] result in
			switch result {
			case .success(let model):
				self.model = .success(model)
				self.output?.update(model: model, deletedRow: nil)
			case .failure(let error):
				self.model = .failure(error)
				self.output?.show(error: error)
			}
		}
	}

	func delete(field: Model.Field, at row: Int) {
		do {
			guard
				case .success(var model) = model,
				model.data.indices.contains(row)
			else {
				throw ListPresenterError.internalInconsistency // Never called actually.
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

	func showDetail(for field: Model.Field, with index: Int) {
		model?.mapIfSuccess { model in
			showDetail?(field, index, model)
		}
	}

}

protocol ListPresenterOutput: AnyObject {
	func update(model: Model, deletedRow: Int?)
	func update(model: Model, updateRow: Int)
	func show(error: Error)
}

extension ListPresenter {
	enum ListPresenterError: Error {
		case internalInconsistency
	}
}
