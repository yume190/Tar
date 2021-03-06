//
//  TarTests.swift
//  TarTests
//
//  Created by Pruthvikar Reddy on 25/04/2016.
//  Copyright © 2016 Pruthvikar Reddy. All rights reserved.
//

import XCTest
@testable import Tar

class TarTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testArchiveZLIB() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "zlib")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))).compressedData(.zlib)!
    if testData != data {

      XCTFail("ZLIB Archive - files are not equal")
    }
  }

  func testArchiveLZMA() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lzma")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))).compressedData(.lzma)!
    if testData != data {
      XCTFail("LZMA Archive - files are not equal")
    }
  }

  func testArchiveLZ4() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lz4")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))).compressedData(.lz4)!
    if testData != data {
      XCTFail("LZ4 Archive - files are not equal")
    }
  }

  func testArchiveLZFSE() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lzfse")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))).compressedData(.lzfse)!
    if testData != data {

      XCTFail("LZFSE Archive - files are not equal")
    }
  }


  func testUnarchiveZLIB() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "zlib")!))).decompressedData(.zlib)!
    if testData != data {

      XCTFail("ZLIB Unarchive - files are not equal")
    }
  }

  func testUnarchiveLZMA() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lzma")!))).decompressedData(.lzma)!
    if testData != data {
      XCTFail("LZMA Unarchive - files are not equal")
    }
  }

  func testUnarchiveLZFSE() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lzfse")!))).decompressedData(.lzfse)!
    if testData != data {
      XCTFail("LZFSE Unarchive - files are not equal")
    }
  }

  func testUnarchiveLZ4() {
    let testData = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "txt")!))

    let data = (try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "lz4")!))).decompressedData(.lz4)!
    if testData != data {
      XCTFail("LZ4 Unarchive - files are not equal")
    }
  }

  func testTar() {
    let testData = Tar.tar(Bundle(for: TarTests.self).path(forResource: "tar", ofType: "")!)

    let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "tar")!))

    if !(testData.count == data.count){
      XCTFail("Tar - data is not equal")
    }
  }

  func testUntar() {
    let testPath = NSTemporaryDirectory().stringByAppendingPathComponent(UUID().uuidString)
    Tar.untar(try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: TarTests.self).path(forResource: "TestData", ofType: "tar")!)), toPath: testPath)
    let dataPath = Bundle(for: TarTests.self).path(forResource: "tar", ofType: "")!
    print("datapath ",dataPath,"\ntestPath",testPath)
    if !(FileManager.default.contentsEqual(atPath: dataPath.stringByAppendingPathComponent("TestData"), andPath: testPath.stringByAppendingPathComponent("TestData"))){
      XCTFail("Untar - data is not equal")
    }
  }
  
}
