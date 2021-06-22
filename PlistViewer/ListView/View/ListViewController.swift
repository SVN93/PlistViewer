//
//  ListViewController.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import UIKit

final class ListViewController: UITableViewController {

	private let output: ListViewControllerOutput
	private var model: Model? {
		didSet {
			if oldValue != model {
				tableView.reloadData()
			}
		}
	}

	init(output: ListViewControllerOutput) {
		self.output = output
		super.init(style: .grouped)
		title = "List"
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(ListViewCell.self, forCellReuseIdentifier: "listViewCellReuseIdentifier")
		tableView.estimatedRowHeight = 60
		tableView.rowHeight = UITableView.automaticDimension
		output.readPlist()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model?.data.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellReuseIdentifier = "listViewCellReuseIdentifier"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? ListViewCell else {
			fatalError("Cannot dequeue ListViewCell for indexPath: \(indexPath)")
		}
		cell.viewModel = model.map { model -> ListViewCell.ViewModel in
			let field = model.data[indexPath.row]
			return ListViewCell.ViewModel(scheme: model.scheme, field: field)
		}
		return cell
	}

	// MARK: - Table view delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

extension ListViewController: ListPresenterOutput {

	func show(model: Model) {
		self.model = model
	}

	func show(error: Error) {
		// TODO:
	}

}

protocol ListViewControllerOutput {
	func readPlist()
}
