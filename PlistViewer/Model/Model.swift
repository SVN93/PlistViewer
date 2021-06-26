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

extension String {

	func validate(with type: Model.ValueType) throws -> Bool {
		switch type {
		case .string:
			return true
		case .date:
			let range = NSMakeRange(0, count)
			let types: NSTextCheckingResult.CheckingType = [.date]
			guard let dateDetector = try? NSDataDetector(types: types.rawValue) else { return false }
			let matches = dateDetector.matches(in: self, options: [], range: range)
			guard !matches.isEmpty else { return false }
			return matches.contains(where: { NSEqualRanges($0.range, range) })
		case .number:
			return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
		}
	}
}

extension Model {

	enum ValidationError: Swift.Error {
		case valueShouldntBeEmpty(Identifier)
		case wrongType(Identifier)
	}

	func validateByScheme() throws {
		for field in data {
			for (id, value) in field {
				guard let config = scheme.config(for: id) else { continue } // Identifier cannot be mapped wrong.
				if config.isRequired {
					guard !value.isEmpty else {
						throw ValidationError.valueShouldntBeEmpty(id)
					}
				}

				guard try value.validate(with: config.type) else {
					throw ValidationError.wrongType(id)
				}
			}
		}
	}

}

extension Model.Field {

	func sorted(by scheme: Model.Scheme) -> [(Model.Identifier, String)] {
		let schemeIds = scheme.map { $0.identifier }
		return sorted(by: { schemeIds.firstIndex(of: $0.key) < schemeIds.firstIndex(of: $1.key) })
	}

}

extension Optional: Comparable where Wrapped == Array<Model.Identifier>.Index {

	public static func < (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
		switch (lhs, rhs) {
		case let (.some(lhsValue), .some(rhsValue)):
			return lhsValue < rhsValue
		case (.some, .none): // Order values before nils
			return false
		case (.none, .some):
			return true
		case (.none, .none): // All none are equivalent, so none is before any other
			return false
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
