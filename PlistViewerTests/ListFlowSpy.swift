//
//  ListFlowSpy.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

@testable import PlistViewer

final class ListFlowSpy: ListFlow {

	var saveModel: SaveModel?
	var showDetail: ShowDetail?
	var updatedField: Model.Field?
	var updatedIndex: Int?
	var updatedModel: Model?

	func update(field: Model.Field, at index: Int, for model: Model) {
		updatedField = field
		updatedIndex = index
		updatedModel = model
	}

}
