//
//  Model.swift
//  PlistReader
//
//  Created by Vladislav.S on 19.06.2021.
//

import Foundation

struct Model: Hashable {

	enum Identifier: String, Codable, Hashable {
		case name, lastName, birthdate, childrenCount
	}

	struct FieldConfiguration: Codable, Hashable {
		enum CodingKeys: String, CodingKey {
			case identifier = "id"
			case type
			case title
			case isRequired = "required"
		}

		let identifier: Identifier
		let type: String
		let title: String
		let isRequired: Bool
	}

	enum CodingKeys: String, CodingKey {
		case scheme, data
	}

	typealias Scheme = [FieldConfiguration]
	typealias Field = [Identifier: String]
	typealias Data = [Field]

	let scheme: Scheme
	var data: Data

}

extension Model {

	enum Error: LocalizedError {
		case invalidField

		var errorDescription: String? {
			switch self {
			case .invalidField:
				return "Invalid field!"
			}
		}
	}

}

extension Model {

	func validateByScheme() throws {
		for field in data {
			for (id, value) in field {
				if let config = scheme.config(for: id), config.isRequired { // Identifier cannot be mapped wrong.
					guard !value.isEmpty else {
						throw Error.invalidField
					}
					// TODO: Check type.
				}
			}
		}
	}

}

extension Array where Element == Model.FieldConfiguration {

	func config(for identifier: Model.Identifier) -> Element? {
		lazy.first(where: { $0.identifier == identifier })
	}

	func title(for identifier: Model.Identifier) -> String? {
		config(for: identifier)?.title
	}

}

extension Model: Decodable {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		scheme = try container.decode(Scheme.self, forKey: .scheme)
		let dictArray = try container.decode([[String: String]].self, forKey: .data)
		data = try dictArray.lazy.map({ dict in
			let sequence = try dict.lazy.compactMap { (key: String, value: String) -> (Identifier, String)? in
				guard !value.isEmpty else { return nil }
				guard let id = Identifier(rawValue: key) else {
					throw DecodingError.dataCorruptedError(
						forKey: CodingKeys.data,
						in: container,
						debugDescription: "Invalid key: '\(key)'"
					)
				}
				return (id, value)
			}
			return Dictionary(uniqueKeysWithValues: sequence)
		})
	}

}

extension Model: Encodable {

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(scheme, forKey: .scheme)
		let stringData = data.map { typedDict -> [String: String] in
			let sequence = typedDict.lazy.map { ($0.key.rawValue, $0.value) }
			return Dictionary(uniqueKeysWithValues: sequence)
		}
		try container.encode(stringData, forKey: .data)
	}

}
