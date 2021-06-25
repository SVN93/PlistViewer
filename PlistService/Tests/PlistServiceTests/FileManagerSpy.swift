//
//  FileManagerSpy.swift
//  
//
//  Created by Vladislav.S on 25.06.2021.
//

import Foundation.NSFileManager

final class FileManagerSpy: FileManager {

	struct FileInfo: Equatable {
		let filePath: String
		let content: Data?
	}

	var isFileExists = true
	var urlsCalled = false
	var fileExistCalled = false
	var fileInfo: FileInfo?

	override func urls(
		for directory: FileManager.SearchPathDirectory,
		in domainMask: FileManager.SearchPathDomainMask
	) -> [URL] {
		urlsCalled = true
		return super.urls(for: directory, in: domainMask)
	}

	override func fileExists(atPath path: String) -> Bool {
		fileExistCalled = true
		return isFileExists
	}

	override func createFile(
		atPath path: String,
		contents data: Data?,
		attributes attr: [FileAttributeKey : Any]? = nil
	) -> Bool {
		fileInfo = .init(filePath: path, content: data)
		return true
	}
}
