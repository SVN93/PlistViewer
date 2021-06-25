//
//  Globals.swift
//  PlistViewer
//
//  Created by Vladislav.S on 23.06.2021.
//

import UIKit

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
