//
//  PlistReaderService.swift
//  PlistReader
//
//  Created by Vladislav.S on 19.06.2021.
//

import Foundation.NSFileManager
import Foundation.NSData

public final class PlistReaderService {

	private let fileManager: FileManager
	private let directory: FileManager.SearchPathDirectory
	private let domainMask: FileManager.SearchPathDomainMask
	internal typealias PlistUrlProvider = (_ resourceName: String?, _ ext: String?) -> URL?
	private let plistUrlProvider: PlistUrlProvider
	internal typealias DataReader = (_ contentsOfUrl: URL) throws -> Data
	private let dataReader: DataReader
	internal typealias DataWriter = (_ dataToWrite: Data, _ toUrl: URL) throws -> Void
	private let dataWriter: DataWriter
	private let decoder = PropertyListDecoder()
	private let encoder = PropertyListEncoder()
	private let bundlePlistName: String
	private var supportedDirectories: [URL] { fileManager.urls(for: directory, in: domainMask) }

	internal init(
		fileManager: FileManager = .default,
		directory: FileManager.SearchPathDirectory = .documentDirectory,
		domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
		plistUrlProvider: @escaping PlistUrlProvider,
		dataReader: @escaping DataReader = { try Data(contentsOf: $0) },
		dataWriter: @escaping DataWriter = { try $0.write(to: $1) },
		bundlePlistName: String
	) { // Testable init
		self.fileManager = fileManager
		self.directory = directory
		self.domainMask = domainMask
		self.plistUrlProvider = plistUrlProvider
		self.dataReader = dataReader
		self.dataWriter = dataWriter
		self.bundlePlistName = bundlePlistName
	}

	public convenience init(
		fileManager: FileManager = .default,
		directory: FileManager.SearchPathDirectory = .documentDirectory,
		domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
		bundlePlistName: String
	) { // Production init
		self.init(
			fileManager: fileManager,
			directory: directory,
			domainMask: domainMask,
			plistUrlProvider: Bundle.main.url(forResource:withExtension:),
			bundlePlistName: bundlePlistName
		)
	}

	private func constructFileURL(for fileName: String) -> URL {
		supportedDirectories[0].appendingPathComponent(fileName)
	}

	private func plistUrl(for fileName: String) throws -> URL {
		let fileUrl = constructFileURL(for: fileName)
		guard !fileManager.fileExists(atPath: fileUrl.path) else { return fileUrl }
		guard let bundlePlistUrl = plistUrlProvider(bundlePlistName, "plist") else {
			throw PlistServiceError.fileNotFound(fileName: bundlePlistName.appending(".plist"))
		}
		return bundlePlistUrl
	}

}

extension PlistReaderService: PlistService {

	public func readValue<Value: Decodable>(from fileName: String) throws -> Value {
		let plistUrl = try plistUrl(for: fileName)
		let data = try dataReader(plistUrl)
		let value = try decoder.decode(Value.self, from: data)
		return value
	}

	public func write<Value: Encodable>(value: Value, to fileName: String) throws {
		let fileUrl = constructFileURL(for: fileName)
		let data = try encoder.encode(value)
		if fileManager.fileExists(atPath: fileUrl.path) {
			try dataWriter(data, fileUrl)
		} else {
			guard fileManager.createFile(atPath: fileUrl.path, contents: data) else {
				throw PlistServiceError.cannotCreateFile(atPath: fileUrl.path)
			}
		}
	}

}
