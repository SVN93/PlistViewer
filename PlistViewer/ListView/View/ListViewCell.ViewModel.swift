//
//  ListViewCell.ViewModel.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

extension ListViewCell {

	struct ViewModel {

		let field: Model.Field
		let name: TitledValueView.ViewModel
		let lastName: TitledValueView.ViewModel?
		let birthdate: TitledValueView.ViewModel
		let childrenCount: TitledValueView.ViewModel?
		typealias DeleteAction = (_ viewModelToDelete: Self) -> Void
		let deleteAction: DeleteAction?

		init(scheme: Model.Scheme, field: Model.Field, deleteAction: @escaping DeleteAction) {
			self.field = field
			self.name = .init(title: scheme.title(for: .name), value: field[.name])
			self.lastName = field[.lastName].map { .init(title: scheme.title(for: .lastName), value: $0) }
			self.birthdate = .init(title: scheme.title(for: .birthdate), value: field[.birthdate])
			self.childrenCount = field[.childrenCount].map { .init(title: scheme.title(for: .childrenCount), value: $0) }
			self.deleteAction = deleteAction
		}
	}

}

extension ListViewCell.ViewModel: Equatable {

	static func == (lhs: ListViewCell.ViewModel, rhs: ListViewCell.ViewModel) -> Bool {
		lhs.field == rhs.field && lhs.name == rhs.name && lhs.lastName == rhs.lastName
			&& lhs.birthdate == rhs.birthdate && lhs.childrenCount == rhs.childrenCount
	}

}
