//
//  Model.Mock.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

@testable import PlistViewer

extension Model {

	static let mock: Self = .init(
		scheme: [
			.init(identifier: .name, type: .string, title: "Имя", isRequired: true),
			.init(identifier: .lastName, type: .string, title: "Фамилия", isRequired: false),
			.init(identifier: .birthdate, type: .date, title: "Дата рождения", isRequired: true),
			.init(identifier: .childrenCount, type: .number, title: "Количество детей", isRequired: false),
		],
		data: [
			[
				.birthdate: "17.08.1955",
				.name: "Маша"
			],
			[
				.birthdate: "17.08.1955",
				.lastName: "Волошин",
				.name: "Денис"
			],
			[
				.childrenCount: "5",
				.birthdate: "12.12.1993",
				.lastName: "Петров",
				.name: "Степа"
			],
			[
				.birthdate: "4.05.1974",
				.name: "Оксана"
			],
			[
				.childrenCount: "1",
				.birthdate: "12.02.1995",
				.lastName: "Иванов",
				.name: "Сергей"
			],
		]
	)

}
