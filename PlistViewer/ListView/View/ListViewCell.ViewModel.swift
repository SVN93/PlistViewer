//
//  ListViewCell.ViewModel.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

extension ListViewCell {

	struct ViewModel {

		let field: Model.Field
		let viewModels: [TitledValueView.ViewModel]
		typealias DeleteAction = (_ viewModelToDelete: Self) -> Void
		let deleteAction: DeleteAction?

		init(scheme: Model.Scheme, field: Model.Field, deleteAction: @escaping DeleteAction) {
			self.field = field
			self.viewModels = field.sorted(by: scheme).map { id, value in
				.init(title: scheme.title(for: id), value: value)
			}
			self.deleteAction = deleteAction
		}
	}

}

extension ListViewCell.ViewModel: Equatable {

	static func == (lhs: ListViewCell.ViewModel, rhs: ListViewCell.ViewModel) -> Bool {
		lhs.field == rhs.field && lhs.viewModels == rhs.viewModels
	}

}
