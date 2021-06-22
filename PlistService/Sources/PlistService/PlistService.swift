//
//  PlistService.swift
//  PlistReader
//
//  Created by Vladislav.S on 19.06.2021.
//

public protocol PlistService  {
	func readValue<Value: Decodable>(from fileName: String) throws -> Value
	func write<Value: Encodable>(value: Value, to fileName: String) throws
}

public enum PlistServiceError: Error {
	case fileNotFound(fileName: String)
	case cannotCreateFile(atPath: String)
}
