//
//  Globals.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

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

extension Sequence where Element: UIView {

	func setTranslatesAutoresizingMaskIntoConstraints(_ value: Bool = false) {
		forEach { $0.translatesAutoresizingMaskIntoConstraints = value }
	}

}

extension Result {

	@inlinable
	@discardableResult
	func mapIfSuccess<NewSuccess>(_ transform: (Success) throws -> NewSuccess) rethrows -> NewSuccess? {
		switch self {
		case .success(let success):
			return try transform(success)
		case .failure:
			return nil
		}
	}

}
