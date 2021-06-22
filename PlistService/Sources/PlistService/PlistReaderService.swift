//
//  PlistReaderService.swift
//  PlistReader
//
//  Created by Vladislav.S on 19.06.2021.
//

import Foundation

public final class PlistReaderService {

	private let fileManager: FileManager
	private let directory: FileManager.SearchPathDirectory
	private let domainMask: FileManager.SearchPathDomainMask
	private let decoder = PropertyListDecoder()
	private let encoder = PropertyListEncoder()
	private let bundlePlistName: String
	private var supportedDirectories: [URL] { fileManager.urls(for: directory, in: domainMask) }

	public init(
		fileManager: FileManager = .default,
		directory: FileManager.SearchPathDirectory = .documentDirectory,
		domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
		bundlePlistName: String
	) {
		self.fileManager = fileManager
		self.directory = directory
		self.domainMask = domainMask
		self.bundlePlistName = bundlePlistName
	}

	private func plistUrl(for fileName: String) throws -> URL {
		let fileUrl = supportedDirectories[0].appendingPathComponent(fileName)
		guard !fileManager.fileExists(atPath: fileUrl.path) else { return fileUrl }
		guard let bundlePlistUrl = Bundle.main.url(forResource: bundlePlistName, withExtension: "plist") else {
			throw PlistServiceError.fileNotFound(fileName: bundlePlistName.appending(".plist"))
		}
		return bundlePlistUrl
	}

}

extension PlistReaderService: PlistService {

	public func readValue<Value: Decodable>(from fileName: String) throws -> Value {
		let plistUrl = try plistUrl(for: fileName)
		let data = try Data(contentsOf: plistUrl)
		let value = try decoder.decode(Value.self, from: data)
		return value
	}

	public func write<Value: Encodable>(value: Value, to fileName: String) throws {
		let plistUrl = try plistUrl(for: fileName)
		let data = try encoder.encode(value)
		if fileManager.fileExists(atPath: plistUrl.path) {
			try data.write(to: plistUrl)
		} else {
			guard fileManager.createFile(atPath: plistUrl.path, contents: data) else {
				throw PlistServiceError.cannotCreateFile(atPath: plistUrl.path)
			}
		}
	}

}
