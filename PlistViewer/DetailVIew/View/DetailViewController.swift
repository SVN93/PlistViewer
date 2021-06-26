//
//  DetailViewController.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

final class DetailViewController: UIViewController {

	private let output: DetailViewControllerOutput
	private var detailView: DetailView { view as! DetailView }
	private var field: Model.Field
	private var model: Model
	private var viewModels: [DetailValueView.ViewModel]
	private var valueViews: [DetailValueView] = []

	init(output: DetailViewControllerOutput, field: Model.Field, model: Model, title: String = "Detail") {
		self.output = output
		self.field = field
		self.model = model
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
		view = DetailView()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(_:)))
		valueViews = viewModels.lazy.map(DetailValueView.init(viewModel:))
		valueViews.forEach(detailView.stackView.addArrangedSubview(_:))
    }

	@objc private func saveButtonTapped(_ saveButton: UIBarButtonItem) {
		do {
			try valueViews.forEach { valueView in
				var viewModel = valueView.viewModel
				let isValid = try viewModel.value.validate(with: viewModel.config.type)
				viewModel.mode = isValid ? .normal : .wrong
				valueView.viewModel = viewModel
			}
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
	
}
