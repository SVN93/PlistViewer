//
//  ListViewCell.ViewModel.swift
//  PlistViewer
//
//  Created by Vladislav.S on 22.06.2021.
//

extension ListViewCell {

	struct ViewModel: Hashable {

		let name: TitledValueView.ViewModel
		let lastName: TitledValueView.ViewModel?
		let birthdate: TitledValueView.ViewModel
		let childrenCount: TitledValueView.ViewModel?

		init(scheme: Model.Scheme, field: Model.Field) {
			self.name = .init(title: scheme.title(for: .name), value: field[.name])
			self.lastName = field[.lastName].map { .init(title: scheme.title(for: .lastName), value: $0) }
			self.birthdate = .init(title: scheme.title(for: .birthdate), value: field[.birthdate])
			self.childrenCount = field[.childrenCount].map { .init(title: scheme.title(for: .childrenCount), value: $0) }
		}
	}

}
