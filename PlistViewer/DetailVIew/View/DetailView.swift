//
//  DetailView.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

final class DetailView: UIScrollView {

	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		return stackView
	}()
	var valueViews: [DetailValueView] {
		stackView.arrangedSubviews as! [DetailValueView]
	}

	init(viewModels: [DetailValueView.ViewModel]) {
		super.init(frame: .zero)
		viewModels.lazy.map(DetailValueView.init(viewModel:)).forEach(stackView.addArrangedSubview(_:))
		backgroundColor = .white
		addSubview(stackView)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: widthAnchor)
		])
	}

}
