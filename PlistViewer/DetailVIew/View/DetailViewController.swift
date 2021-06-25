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

	init(output: DetailViewControllerOutput, field: Model.Field, model: Model, title: String = "Detail") {
		self.output = output
		self.field = field
		self.model = model
		self.viewModels = field.sorted(by: model.scheme).map { id, value in
			.init(title: model.scheme.title(for: id), value: value)
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
		viewModels.lazy.map(DetailValueView.init(viewModel:)).forEach(detailView.stackView.addArrangedSubview(_:))
    }

}

extension DetailViewController: DetailPresenterOutput {
	
}

protocol DetailViewControllerOutput: AnyObject {
	
}
