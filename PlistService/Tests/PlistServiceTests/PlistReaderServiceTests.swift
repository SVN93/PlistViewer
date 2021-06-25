import XCTest
@testable import PlistService

final class PlistReaderServiceTests: XCTestCase {

	private let bundlePlistName = "TestInput"
	private let testFileName = "TestFile"
	private var fileManagerSpy: FileManagerSpy!

	override func setUp() {
		super.setUp()
		fileManagerSpy = FileManagerSpy()
	}

	override func tearDown() {
		fileManagerSpy = nil
		super.tearDown()
	}

	func testReadValue_FileExist() {
		do {
			// Arrange
			let expectedValue = TestValue(value: "test value")
			let encoder = PropertyListEncoder()
			let encodedValue = try encoder.encode(expectedValue)
			var dataReaderCalled = false
			let plistReaderService = PlistReaderService(
				fileManager: fileManagerSpy,
				plistUrlProvider: { _, _ in URL(string: self.bundlePlistName) },
				dataReader: { _ in
					dataReaderCalled = true
					return encodedValue
				},
				bundlePlistName: bundlePlistName
			)

			// Act
			let value: TestValue = try plistReaderService.readValue(from: testFileName)

			// Assert
			XCTAssertTrue(fileManagerSpy.fileExistCalled)
			XCTAssertTrue(dataReaderCalled)
			XCTAssertEqual(expectedValue, value)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testReadValue_NoFile() {
		fileManagerSpy.isFileExists = false
		do {
			// Arrange
			var plistUrlProviderCalled = false
			let expectedValue = TestValue(value: "test value")
			let encoder = PropertyListEncoder()
			let encodedValue = try encoder.encode(expectedValue)
			var dataReaderCalled = false
			let plistReaderService = PlistReaderService(
				fileManager: fileManagerSpy,
				plistUrlProvider: { _, _ in
					plistUrlProviderCalled = true
					return URL(string: self.bundlePlistName)
				},
				dataReader: { _ in
					dataReaderCalled = true
					return encodedValue
				},
				bundlePlistName: bundlePlistName
			)

			// Act
			let value: TestValue = try plistReaderService.readValue(from: testFileName)

			// Assert
			XCTAssertTrue(fileManagerSpy.fileExistCalled)
			XCTAssertTrue(plistUrlProviderCalled)
			XCTAssertTrue(dataReaderCalled)
			XCTAssertEqual(expectedValue, value)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testWriteValue_FileExist() {
		do {
			// Arrange
			let value = TestValue(value: "test value")
			let encoder = PropertyListEncoder()
			let encodedValue = try encoder.encode(value)
			var dataWriterCalled = false
			var result: Data?
			let plistReaderService = PlistReaderService(
				fileManager: fileManagerSpy,
				plistUrlProvider: { _, _ in URL(string: self.bundlePlistName) },
				dataWriter: { data, _ in
					dataWriterCalled = true
					result = data
				},
				bundlePlistName: bundlePlistName
			)

			// Act
			try plistReaderService.write(value: value, to: testFileName)

			// Assert
			XCTAssertTrue(fileManagerSpy.fileExistCalled)
			XCTAssertTrue(dataWriterCalled)
			XCTAssertEqual(encodedValue, result)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testWriteValue_NoFile() {
		fileManagerSpy.isFileExists = false
		do {
			// Arrange
			guard let bundlePlistURL = URL(string: self.bundlePlistName) else {
				return XCTFail("Cannot create url from string: \(self.bundlePlistName)")
			}
			let value = TestValue(value: "test value")
			let encoder = PropertyListEncoder()
			let encodedValue = try encoder.encode(value)
			let fileInfo = FileManagerSpy.FileInfo(filePath: bundlePlistURL.path, content: encodedValue)
			var dataWriterCalled = false
			let plistReaderService = PlistReaderService(
				fileManager: fileManagerSpy,
				plistUrlProvider: { _, _ in
					bundlePlistURL
				},
				dataWriter: { _, _ in
					dataWriterCalled = true
				},
				bundlePlistName: bundlePlistName
			)

			// Act
			try plistReaderService.write(value: value, to: testFileName)

			// Assert
			XCTAssertTrue(fileManagerSpy.fileExistCalled)
			XCTAssertFalse(dataWriterCalled)
			XCTAssertEqual(fileManagerSpy.fileInfo, fileInfo)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

}
