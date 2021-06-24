//
//  ListViewCell.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

import UIKit

final class ListViewCell: UITableViewCell {

	private var titledValueViews = [TitledValueView(), TitledValueView(), TitledValueView(), TitledValueView()] // little optimization
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
				guard let viewModels = viewModel?.viewModels else {
					assertionFailure("No viewModels for cell: \(self)")
					return titledValueViews.forEach { $0.isHidden = true }
				}
				addViewsIfNeeded(for: viewModels)
				for (idx, titledValueView) in titledValueViews.enumerated() {
					if viewModels.indices.contains(idx) {
						titledValueView.viewModel = viewModels[idx]
						titledValueView.isHidden = false
					} else {
						titledValueView.isHidden = true
						titledValueView.viewModel = nil
					}
				}
			}
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		let stackView = UIStackView(arrangedSubviews: titledValueViews + [deleteButton])
		stackView.axis = .vertical
		self.stackView = stackView
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(stackView)
		deleteButton.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addViewsIfNeeded(for viewModels: [TitledValueView.ViewModel]) {
		let viewsCount = titledValueViews.count
		let missing = viewModels.count - viewsCount
		if missing > 0 {
			for idx in 0..<missing {
				let titledValueView = TitledValueView()
				titledValueViews.append(titledValueView)
				let stackIndex = viewsCount + idx
				stackView.insertArrangedSubview(titledValueView, at: stackIndex)
			}
		}
	}

	@objc private func didTapDeleteButton(_ deleteButton: UIButton) {
		viewModel.map { $0.deleteAction?($0) }
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
