//
//  DetailViewController.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

final class DetailViewController: UIViewController {

	private let output: DetailViewControllerOutput
	private var viewModels: [DetailValueView.ViewModel]
	private var detailView: DetailView { view as! DetailView }

	init(output: DetailViewControllerOutput, field: Model.Field, model: Model, title: String = "Detail") {
		self.output = output
		self.viewModels = field.sorted(by: model.scheme).compactMap { id, value in
			guard let config = model.scheme.config(for: id) else { return nil }
			return DetailValueView.ViewModel(id: id, config: config, title: config.title, value: value)
		}
		super.init(nibName: nil, bundle: nil)
		self.title = title
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = DetailView(viewModels: viewModels)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(_:)))
    }

	@objc private func saveButtonTapped(_ saveButton: UIBarButtonItem) {
		do {
			let viewModels = detailView.valueViews.map { $0.viewModel }
			let modifiedField = viewModels.constructField()
			let wrongIds = try output.validate(field: modifiedField)
			guard wrongIds.isEmpty else {
				return detailView.valueViews.forEach {
					$0.viewModel.mode = wrongIds.contains($0.viewModel.id) ? .wrong : .normal
				}
			}
			// Continue saving...
		} catch {
			let alertViewController = UIAlertController(title: "Error ocurred", message: error.localizedDescription, preferredStyle: .alert)
			let retryAction = UIAlertAction(title: "OK", style: .cancel)
			alertViewController.addAction(retryAction)
			present(alertViewController, animated: true)
		}
	}

}

extension DetailViewController: DetailPresenterOutput {
	
}

protocol DetailViewControllerOutput: AnyObject {

	func validate(field: Model.Field) throws -> Set<Model.Identifier>


}
