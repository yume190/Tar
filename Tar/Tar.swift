//
//  Tar.swift
//  Tar
//
//  Created by Pruthvikar Reddy on 25/04/2016.
//  Copyright © 2016 Pruthvikar Reddy. All rights reserved.
//

import Foundation

extension String {
  func stringByAppendingPathComponent(_ pathComponent: String) -> String {
    return (self as NSString).appendingPathComponent(pathComponent)
  }
}

extension Tar {


  public static func untar(_ path: String, toPath: String, using: Data.Algorithm? = nil) {
    let data : Data = {
      if let algorithm = using {
        return (try! Data(contentsOf: URL(fileURLWithPath: path))).decompressedData(algorithm)!
      } else {
        return (try! Data(contentsOf: URL(fileURLWithPath: path)))
      }
    }()
    _untar(data, toPath: toPath)
  }

  public static func untar(_ data:Data, toPath: String, using: Data.Algorithm? = nil) {
      if let algorithm = using {
        _untar(data.decompressedData(algorithm)!, toPath: toPath)
      } else {
        _untar(data, toPath: toPath)
      }
    }

  public static func tar(_ path: String, toPath: String, exclude: [String]? = nil, using: Data.Algorithm? = nil) {
    let data = _tar(path, exclude: exclude)
    if let algorithm = using {
      try? data.compressedData(algorithm)!.write(to: URL(fileURLWithPath: toPath), options: [.atomic])
    } else {
      try? data.write(to: URL(fileURLWithPath: toPath), options: [.atomic])
    }
  }

  public static func tar(_ path:String, exclude: [String]? = nil, using: Data.Algorithm? = nil) -> Data {
    let data = _tar(path, exclude: exclude)
    if let algorithm = using {
      return data.compressedData(algorithm)!
    } else {
      return data
    }
  }

  static func _tar(_ path: String, exclude: [String]? = nil) -> Data {
    let excludePaths = exclude ?? []
    let fm = FileManager.default
    let md = NSMutableData()
    if fm.fileExists(atPath: path) {
      let fileEnumerator = fm.enumerator(atPath: path)
      while let filePath = fileEnumerator?.nextObject() as? String {
        var isDir = ObjCBool(false)
        var skip = false
        for excludePath in excludePaths {
          if filePath.starts(with: excludePath) {
            skip = true
            continue
          }
        }
        if !skip {
          fm.fileExists(atPath: path.stringByAppendingPathComponent(filePath), isDirectory: &isDir)
          let tarContent = binaryEncodeData(filePath, inDirectory: path, isDirectory: isDir)
          md.append(tarContent)
        }
      }
      var block = [UInt8](repeating: UInt8(), count: TAR_BLOCK_SIZE * 2)
      memset(&block, Int32(NullChar), TAR_BLOCK_SIZE * 2)
      md.append(Data(bytes: UnsafePointer<UInt8>(UnsafePointer<UInt8>(block)), count: block.count))
      return md as Data
    }
    return Data()
  }

  static func _untar(_ data: Data, toPath: String) {
    let fileManager = FileManager.default
    try! fileManager.createDirectory(atPath: toPath, withIntermediateDirectories: true, attributes: nil)

    var location : Int = 0

    while location < data.count {
      var blockCount : Int = 1
      let type = typeFor(data, atOffset: location)
      if type == NullChar || type == ZeroChar {
        let name = nameFor(data, atOffset: location)
        let filePath = toPath.stringByAppendingPathComponent(name)
        let size = sizeFor(data, atOffset: location)
        blockCount += (size - 1) / (TAR_BLOCK_SIZE) + 1
        writeFileDataFor(data, atLocation: location + TAR_BLOCK_SIZE, withLength: size, atPath: filePath)
      } else if type == 53 {
        let name = nameFor(data, atOffset: location)
        let directoryPath = toPath.stringByAppendingPathComponent(name)
        try! fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
      }
      location += blockCount * TAR_BLOCK_SIZE
    }
  }


}

public struct Tar {

  // const definition
  fileprivate static let TAR_BLOCK_SIZE = 512
  fileprivate static let TAR_TYPE_POSITION = 156
  fileprivate static let TAR_NAME_POSITION = 0
  fileprivate static let TAR_NAME_SIZE = 100
  fileprivate static let TAR_SIZE_POSITION = 124
  fileprivate static let TAR_SIZE_SIZE = 12
  fileprivate static let TAR_MAX_BLOCK_LOAD_IN_MEMORY = 100
  /*
   * Define structure of POSIX 'ustar' tar header.
   + Provided by libarchive.
   */
  fileprivate static let	USTAR_name_offset = 0
  fileprivate static let	USTAR_name_size = 100
  fileprivate static let	USTAR_mode_offset = 100
  fileprivate static let	USTAR_mode_size = 6
  fileprivate static let	USTAR_mode_max_size = 8
  fileprivate static let	USTAR_uid_offset = 108
  fileprivate static let	USTAR_uid_size = 6
  fileprivate static let	USTAR_uid_max_size = 8
  fileprivate static let	USTAR_gid_offset = 116
  fileprivate static let	USTAR_gid_size = 6
  fileprivate static let	USTAR_gid_max_size = 8
  fileprivate static let	USTAR_size_offset = 124
  fileprivate static let	USTAR_size_size = 11
  fileprivate static let	USTAR_size_max_size = 12
  fileprivate static let	USTAR_mtime_offset = 136
  fileprivate static let	USTAR_mtime_size = 11
  fileprivate static let	USTAR_mtime_max_size = 11
  fileprivate static let	USTAR_checksum_offset = 148
  fileprivate static let	USTAR_checksum_size = 8
  fileprivate static let	USTAR_typeflag_offset = 156
  fileprivate static let	USTAR_typeflag_size = 1
  fileprivate static let	USTAR_linkname_offset = 157
  fileprivate static let	USTAR_linkname_size = 100
  fileprivate static let	USTAR_magic_offset = 257
  fileprivate static let	USTAR_magic_size = 6
  fileprivate static let	USTAR_version_offset = 263
  fileprivate static let	USTAR_version_size = 2
  fileprivate static let	USTAR_uname_offset = 265
  fileprivate static let	USTAR_uname_size = 32
  fileprivate static let	USTAR_gname_offset = 297
  fileprivate static let	USTAR_gname_size = 32
  fileprivate static let	USTAR_rdevmajor_offset = 329
  fileprivate static let	USTAR_rdevmajor_size = 6
  fileprivate static let	USTAR_rdevmajor_max_size = 8
  fileprivate static let	USTAR_rdevminor_offset = 337
  fileprivate static let	USTAR_rdevminor_size = 6
  fileprivate static let	USTAR_rdevminor_max_size = 8
  fileprivate static let	USTAR_prefix_offset = 345
  fileprivate static let	USTAR_prefix_size = 155
  fileprivate static let	USTAR_padding_offset = 500
  fileprivate static let	USTAR_padding_size = 12

  fileprivate static let NullChar: UInt8 = 0
  fileprivate static let ZeroChar: UInt8 = 48
  fileprivate static let MaxChar: UInt8 = 255
  fileprivate static let directoryFlagChar: UInt8 = 53

  fileprivate static let template_header: [UInt8] = [
    00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 48, 48, 48, 48, 48, 48, 32, 00, 48, 48, 48, 48, 48, 48, 32, 00, 48, 48, 48, 48, 48, 48, 32, 00, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 32, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 32, 32, 32, 32, 32, 32, 32, 32, 32, 48, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 117, 115, 116, 97, 114, 00, 48, 48, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 48, 48, 48, 48, 48, 48, 32, 00, 48, 48, 48, 48, 48, 48, 32, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  ]

  fileprivate static func writeFileDataFor(_ data: Data, atLocation: Int, withLength: Int, atPath: String) {
    FileManager.default.createFile(atPath: atPath, contents: data.subdata(in: atLocation..<(atLocation+withLength)), attributes: nil)
  }

  fileprivate static func typeFor(_ data: Data, atOffset: Int) -> UInt8 {
    var type: UInt8 = 0
    let temp = data.subdata(in: atOffset+TAR_TYPE_POSITION..<atOffset+TAR_TYPE_POSITION+1)
    (temp as NSData).getBytes(&type, length: MemoryLayout<UInt8>.size)
    return type
  }

  fileprivate static func nameFor(_ data: Data, atOffset: Int) -> String {
    let temp = data.subdata(in: atOffset+TAR_NAME_POSITION..<atOffset+TAR_NAME_POSITION+TAR_NAME_SIZE)
    return String(data: temp, encoding:  String.Encoding.ascii)!
  }

  fileprivate static func sizeFor(_ data: Data, atOffset: Int) -> Int {
    let temp = data.subdata(in: atOffset+TAR_SIZE_POSITION..<atOffset+TAR_SIZE_POSITION+TAR_SIZE_SIZE)
    let sizeString = String(data: temp, encoding: String.Encoding.ascii)!
    return strtol(sizeString, nil, 8)
  }


  fileprivate static func binaryEncodeData(_ forPath: String, inDirectory: String, isDirectory: ObjCBool) -> Data {

    let block = writeHeader(forPath, withBasePath: inDirectory, isDirectory: isDirectory)!
    let data = NSMutableData(bytes: block, length: TAR_BLOCK_SIZE)
    if !isDirectory.boolValue {
      let path = inDirectory + "/" + forPath

      data.append(getContentsAsArray(path))
    }

    return data as Data
  }

  fileprivate static func writeHeader(_ forPath: String, withBasePath: String, isDirectory: ObjCBool) -> [UInt8]? {

    var buffer = template_header

    let attributesOptional = try? FileManager.default.attributesOfItem(atPath: withBasePath.stringByAppendingPathComponent(forPath))
    guard attributesOptional != nil else {
      return nil
    }
    var path =  forPath
    if isDirectory.boolValue {
      path += "/"
    }

    let attributes : NSDictionary = attributesOptional! as NSDictionary

    let permissions = Int64(attributes.filePosixPermissions())
    let modificationDate = Int64(attributes.fileModificationDate()!.timeIntervalSince1970)
    let ownerId = Int64(attributes.fileOwnerAccountID()!.intValue)
    let groupId = Int64(attributes.fileGroupOwnerAccountID()!.intValue)
    let ownerName = attributes.fileOwnerAccountName() ?? ""
    let groupName = attributes.fileGroupOwnerAccountName() ?? ""
    let fileSize = Int64(attributes.fileSize())
    let nameChar = getStringAsArray(path, withLength: USTAR_name_size)
    let unameChar = getStringAsArray(ownerName, withLength: USTAR_uname_size)
    memcpy(&buffer[USTAR_uname_offset], unameChar, unameChar.count)
    let gnameChar = getStringAsArray(groupName, withLength: USTAR_gname_size)
    memcpy(&buffer[USTAR_gname_offset], gnameChar, gnameChar.count)
    formatNumber(permissions & 4095, buffer: &buffer, offset: USTAR_mode_offset, size: USTAR_mode_size, maxsize: USTAR_mode_max_size)
    formatNumber(ownerId, buffer: &buffer, offset: USTAR_uid_offset, size: USTAR_uid_size, maxsize: USTAR_uid_max_size)
    formatNumber(groupId, buffer: &buffer, offset: USTAR_gid_offset, size: USTAR_gid_size, maxsize: USTAR_gid_max_size)
    formatNumber(fileSize, buffer: &buffer, offset: USTAR_size_offset, size: USTAR_size_size, maxsize: USTAR_size_max_size)
    formatNumber(modificationDate, buffer: &buffer, offset: USTAR_mtime_offset, size: USTAR_mtime_size, maxsize: USTAR_mtime_max_size)
    let nameLength = nameChar.count
    if nameLength <= USTAR_name_size {
      memcpy(&buffer[USTAR_name_offset], nameChar, nameLength)
    } else {
      fatalError("Name too long, not implemented yet")
    }

    if isDirectory.boolValue {
      formatNumber(0, buffer: &buffer, offset: USTAR_size_offset, size: USTAR_size_size, maxsize: USTAR_size_max_size)
      buffer[USTAR_typeflag_offset] = directoryFlagChar
    }

    var checksum: UInt64 = 0

    for i in buffer {
      checksum = checksum + (255 & UInt64(i))
    }

    buffer[USTAR_checksum_offset + 6] = NullChar
    formatOctal(Int64(checksum), buffer: &buffer, offset: USTAR_checksum_offset, size: 6)
    return buffer

  }

  fileprivate static func getContentsAsArray(_ path: String) -> Data {
    let content = try! Data(contentsOf: URL(fileURLWithPath: path))
    let contentSize = content.count
    let padding = (TAR_BLOCK_SIZE - (contentSize % TAR_BLOCK_SIZE)) % TAR_BLOCK_SIZE
    var buffer = [UInt8](repeating: UInt8(), count: padding)
    memset(&buffer, Int32(NullChar), padding)
    var data = NSData(data: content) as Data
    data.append(buffer, count: padding)
    return data
  }


  fileprivate static func getStringAsArray(_ string: String, withLength: Int) -> [UInt8] {
    let stringData = string.data(using: String.Encoding.ascii)
    var charArray = [UInt8](repeating: UInt8(), count: withLength)
    (stringData as NSData?)?.getBytes(&charArray, length:(stringData?.count)!)
    return charArray
  }

  fileprivate static func formatNumber(_ value: Int64, buffer: inout [UInt8], offset: Int, size: Int, maxsize: Int) {
    var limit: Int64 = 1 << (Int64(size) * 3)

    if value >= 0 {
      for _ in size...maxsize {
        if value < limit {
          return formatOctal(value, buffer: &buffer, offset: offset, size: size)
        }
        limit <<= 3
      }
    }
    format256(value, buffer: &buffer, offset: offset, maxsize: maxsize)
    return

  }

  fileprivate static func formatOctal(_ value: Int64, buffer: inout [UInt8], offset: Int, size: Int) {
    let len = size

    if value < 0 {
      for i in 0..<len {
        buffer[offset + i] = ZeroChar
      }
      return
    }

    var valueCopy = value

    for i in 1...size {
      buffer[offset + size - i] = ZeroChar + UInt8(valueCopy & 7)
      valueCopy >>= 3
    }

    if valueCopy == 0 {
      return
    }

    for _ in 0..<len {
      buffer[offset] = MaxChar
    }

    return
  }


  fileprivate static func format256(_ value: Int64, buffer: inout [UInt8], offset: Int, maxsize: Int) {
    var valueCopy = value
    for i in 0..<maxsize {
      buffer[offset + maxsize - i] = UInt8(valueCopy & 0xff)
      valueCopy >>= 8
    }
    buffer[offset] |= 0x80
    
  }
}
