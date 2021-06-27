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

	enum ValueType: String, Codable, Hashable {
		case string, date, number
	}

	struct FieldConfiguration: Codable, Hashable {
		enum CodingKeys: String, CodingKey {
			case identifier = "id"
			case type
			case title
			case isRequired = "required"
		}

		let identifier: Identifier
		let type: ValueType
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

extension Sequence where Element == Model.FieldConfiguration {

	func config(for identifier: Model.Identifier) -> Element? {
		lazy.first(where: { $0.identifier == identifier })
	}

	func title(for identifier: Model.Identifier) -> String? {
		config(for: identifier)?.title
	}

}

extension String {

	func isValid(byIts type: Model.ValueType) throws -> Bool {
		switch type {
		case .string:
			return true
		case .date:
			let range = NSMakeRange(0, count)
			let types: NSTextCheckingResult.CheckingType = [.date]
			let dateDetector = try NSDataDetector(types: types.rawValue)
			let matches = dateDetector.matches(in: self, options: [], range: range)
			guard !matches.isEmpty else { return false }
			return matches.contains(where: { NSEqualRanges($0.range, range) })
		case .number:
			return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
		}
	}
}

extension Model.Field {

	enum ValidationError: Swift.Error, Hashable {
		case valueShouldntBeEmpty(Model.Identifier)
		case wrongType(Model.Identifier)

		var identifier: Model.Identifier {
			switch self {
			case .valueShouldntBeEmpty(let id):
				return id
			case .wrongType(let id):
				return id
			}
		}
	}

	func validate(by scheme: Model.Scheme) throws {
		for (id, value) in self {
			guard let config = scheme.config(for: id) else { continue } // Identifier cannot be mapped wrong.
			if config.isRequired {
				guard !value.isEmpty else {
					throw ValidationError.valueShouldntBeEmpty(id)
				}
			}

			guard try value.isValid(byIts: config.type) else {
				throw ValidationError.wrongType(id)
			}
		}
	}

	func validateAllValues(by scheme: Model.Scheme) throws -> Set<ValidationError> {
		var wrongIds: Set<ValidationError> = []
		for (id, value) in self {
			guard let config = scheme.config(for: id) else { continue } // Identifier cannot be mapped wrong.
			if config.isRequired {
				if value.isEmpty {
					wrongIds.insert(ValidationError.valueShouldntBeEmpty(id))
				}
			}

			let isValid = try value.isValid(byIts: config.type)
			if !isValid {
				wrongIds.insert(ValidationError.wrongType(id))
			}
		}
		return wrongIds
	}

	func sorted(by scheme: Model.Scheme) -> [(Model.Identifier, String)] {
		let schemeIds = scheme.map { $0.identifier }
		return sorted(by: { schemeIds.firstIndex(of: $0.key) < schemeIds.firstIndex(of: $1.key) })
	}

}

extension Model {

	func validateByScheme() throws {
		for field in data {
			try field.validate(by: scheme)
		}
	}

}

extension Model: Decodable {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		scheme = try container.decode(Scheme.self, forKey: .scheme)
		let dictArray = try container.decode([[String: String]].self, forKey: .data)
		data = try dictArray.lazy.map { dict in
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
		}
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
