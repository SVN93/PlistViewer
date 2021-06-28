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
			return DetailValueView.ViewModel(id: id, title: config.title, value: value)
		}
		super.init(nibName: nil, bundle: nil)
		self.title = title
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
		let viewModels = detailView.valueViews.map { $0.viewModel }
		output.validateAndSaveIfValid(modifiedField: viewModels.field)
	}

	@objc func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

		let keyboardScreenEndFrame = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			detailView.contentInset = .zero
		} else {
			detailView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}

		if let activeField = detailView.valueViews.first(where: { $0.isFirstResponder }) {
			detailView.scrollIndicatorInsets = activeField.textView.contentInset

			let selectedRange = activeField.textView.selectedRange
			activeField.textView.scrollRangeToVisible(selectedRange)
		}
	}

}

extension DetailViewController: DetailPresenterOutput {

	func markInvalidValues(with identifiers: Set<Model.Identifier>) {
		if !identifiers.isEmpty {
			detailView.valueViews.forEach {
				$0.viewModel.mode = identifiers.contains($0.viewModel.id) ? .wrong : .normal
			}
		}
	}

	func show(error: Error) {
		let alertViewController = UIAlertController(title: "Error ocurred", message: error.localizedDescription, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .cancel)
		alertViewController.addAction(okAction)
		present(alertViewController, animated: true)
	}

}

protocol DetailViewControllerOutput: AnyObject {
	func validateAndSaveIfValid(modifiedField: Model.Field)
}
