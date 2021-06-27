//
//  PlistServiceSpy.swift
//  PlistViewerTests
//
//  Created by Vladislav.S on 27.06.2021.
//

import PlistService

final class PlistServiceSpy<Model: Codable> {

	let model: Model
	private(set) var writtenValue: Model?
	private(set) var readFileName: String?
	private(set) var writeFileName: String?

	init(model: Model) {
		self.model = model
	}

}

extension PlistServiceSpy: PlistService {

	func readValue<Value: Decodable>(from fileName: String) throws -> Value {
		readFileName = fileName
		return model as! Value
	}

	func write<Value: Encodable>(value: Value, to fileName: String) throws {
		writeFileName = fileName
		writtenValue = value as? Model
	}

}
