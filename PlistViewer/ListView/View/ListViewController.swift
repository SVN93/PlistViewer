//
//  ListViewController.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import UIKit

final class ListViewController: UITableViewController {

	private var viewModel: Result<Model, Error>?
	private let output: ListViewControllerOutput
	private var lastSelectedIndexPath: IndexPath?
	private let cellReuseIdentifier = "listViewCellReuseIdentifier"

	init(output: ListViewControllerOutput, title: String = "List") {
		self.output = output
		super.init(style: .grouped)
		self.title = title
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(ListViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
		tableView.estimatedRowHeight = 60
		tableView.rowHeight = UITableView.automaticDimension
		output.requestViewModel()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		lastSelectedIndexPath.map { tableView.deselectRow(at: $0, animated: animated) }
	}

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel?.mapIfSuccess { $0.data.count } ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: cellReuseIdentifier, for: indexPath
		) as? ListViewCell else {
			fatalError("Cannot dequeue `ListViewCell` for indexPath: \(indexPath)")
		}
		cell.viewModel = viewModel?.mapIfSuccess { model -> ListViewCell.ViewModel in
			let field = model.data[indexPath.row]
			return ListViewCell.ViewModel(
				scheme: model.scheme,
				field: field,
				deleteAction: { [unowned output] viewModelToDelete in
					output.delete(field: viewModelToDelete.field, at: indexPath.row)
				}
			)
		}
		return cell
	}

	// MARK: - Table view delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		lastSelectedIndexPath = indexPath
		guard case .success(let model) = viewModel else { return }
		let field = model.data[indexPath.row]
		output.showDetail(for: field, with: indexPath.row)
	}

}

extension ListViewController: ListPresenterOutput {

	func update(model: Model, deletedRow: Int?) {
		viewModel = .success(model)
		switch deletedRow {
		case .none:
			tableView.reloadData()
		case .some(let deletedRow):
			tableView.deleteRows(at: [.init(row: deletedRow, section: 0)], with: .fade)
		}
	}

	func update(model: Model, updateRow: Int) {
		guard
			case .success(let oldModel) = viewModel,
			oldModel != model
		else { return }
		viewModel = .success(model)
		tableView.reloadRows(at: [.init(row: updateRow, section: 0)], with: .automatic)
	}


	func show(error: Error) {
		viewModel = .failure(error)
		let alertViewController = UIAlertController(title: "Error ocurred", message: error.localizedDescription, preferredStyle: .alert)
		let retryAction = UIAlertAction(title: "Retry", style: .default) { [unowned output] action in
			output.requestViewModel()
		}
		alertViewController.addAction(retryAction)
		present(alertViewController, animated: true)
	}

}

protocol ListViewControllerOutput: AnyObject {
	func requestViewModel()
	func delete(field: Model.Field, at row: Int)
	func showDetail(for field: Model.Field, with index: Int)
}
