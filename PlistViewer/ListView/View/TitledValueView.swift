//
//  TitledValueView.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

import UIKit

final class TitledValueView: UIView {

	struct ViewModel: Hashable {
		let title: String?
		let value: String?
	}

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 14)
		label.textColor = .black
		label.numberOfLines = 0
		return label
	}()
	private let valueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.textColor = .black
		label.numberOfLines = 0
		return label
	}()
	var viewModel: ViewModel? {
		didSet {
			titleLabel.text = viewModel?.title
			valueLabel.text = viewModel?.value
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		[titleLabel, valueLabel].forEach(addSubview(_:))
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		[titleLabel, valueLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		let spacing: CGFloat = 10
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
			bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor),
			valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: spacing),
			valueLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
			trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.trailingAnchor),
			bottomAnchor.constraint(greaterThanOrEqualTo: valueLabel.bottomAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

}
