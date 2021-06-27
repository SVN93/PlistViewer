//
//  DetailValueView.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

final class DetailValueView: UIView {

	var viewModel: ViewModel {
		didSet {
			if oldValue != viewModel {
				updateView(with: viewModel)
			}
		}
	}
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 14)
		label.textColor = .black
		label.numberOfLines = 0
		return label
	}()
	private let textView: UITextView = {
		let textView = UITextView()
		textView.isScrollEnabled = false
		textView.isEditable = true
		textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		textView.font = .systemFont(ofSize: 14)
		textView.textColor = .black
		textView.layer.borderWidth = 2
		textView.layer.borderColor = UIColor.black.cgColor
		return textView
	}()

	init(viewModel: ViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		[titleLabel, textView].forEach(addSubview(_:))
		updateView(with: self.viewModel)
		setupLayout()
		textView.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func updateView(with viewModel: ViewModel) {
		titleLabel.text = viewModel.title
		textView.text = viewModel.value
		switch viewModel.mode {
		case .normal:
			titleLabel.textColor = .black
			textView.textColor = .black
			textView.layer.borderColor = UIColor.black.cgColor
		case .wrong:
			titleLabel.textColor = .red
			textView.textColor = .red
			textView.layer.borderColor = UIColor.red.cgColor
		}
	}

	private func setupLayout() {
		[titleLabel, textView].setTranslatesAutoresizingMaskIntoConstraints()
		let titleInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 2)
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: titleInsets.left),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: titleInsets.top),
			safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: titleInsets.right),
			textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleInsets.bottom),
			textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
			safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
		])
	}

}

extension DetailValueView: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		viewModel.value = textView.text
	}

}

extension DetailValueView {

	enum Mode: Hashable {
		case normal, wrong
	}

	struct ViewModel: Hashable {
		let id: Model.Identifier
		let title: String
		var value: String
		var mode: Mode = .normal
	}

}

extension Sequence where Element == DetailValueView.ViewModel {

	var field: Model.Field {
		reduce(into: Model.Field()) { field, nextElement in
			field[nextElement.id] = nextElement.value
		}
	}

}
