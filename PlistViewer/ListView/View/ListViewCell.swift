//
//  ListViewCell.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

import UIKit

final class ListViewCell: UITableViewCell {

	private let nameView = TitledValueView()
	private let lastNameView: TitledValueView = {
		let view = TitledValueView()
		view.isHidden = true
		return view
	}()
	private let birthdateView = TitledValueView()
	private let childrenCountView: TitledValueView = {
		let view = TitledValueView()
		view.isHidden = true
		return view
	}()
	private let deleteButton: UIButton = {
		let deleteButton = UIButton(type: .custom)
		deleteButton.setTitle("Удалить", for: .normal)
		deleteButton.setTitle("😵😵😵", for: .highlighted)
		deleteButton.setTitleColor(.systemRed, for: .normal)
		return deleteButton
	}()
	private let stackView: UIStackView

	var viewModel: ViewModel? {
		didSet {
			if oldValue != viewModel {
				nameView.viewModel = viewModel?.name
				lastNameView.isHidden = viewModel?.lastName == nil ? true : false
				viewModel?.lastName.map { lastNameView.viewModel = $0 }
				lastNameView.viewModel = viewModel?.lastName
				birthdateView.viewModel = viewModel?.birthdate
				lastNameView.isHidden = viewModel?.childrenCount == nil ? true : false
				viewModel?.childrenCount.map { childrenCountView.viewModel = $0 }
			}
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		let stackView = UIStackView(arrangedSubviews: [nameView, lastNameView, birthdateView, childrenCountView, deleteButton])
		stackView.axis = .vertical
		self.stackView = stackView
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(stackView)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
			contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: insets.right),
			contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: insets.bottom)
		])
	}

}
