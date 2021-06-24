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
