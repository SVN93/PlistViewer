//
//  ListPresenter.swift
//  PlistViewer
//
//  Created by Vladislav.S on 20.06.2021.
//

import PlistService

final class ListPresenter {

	private let fileName: String
	private let plistService: PlistService
	weak var output: ListPresenterOutput?

	init(fileName: String, plistService: PlistService) {
		self.fileName = fileName
		self.plistService = plistService
	}

}

extension ListPresenter: ListViewControllerOutput {

	func readPlist() {
		do {
			let model: Model = try plistService.readValue(from: fileName)
			try model.validateByScheme()
			output?.show(model: model)
		} catch {
			print(error)
			output?.show(error: error)
		}
	}

}

protocol ListPresenterOutput: AnyObject {

	func show(model: Model)

	func show(error: Error)

}
