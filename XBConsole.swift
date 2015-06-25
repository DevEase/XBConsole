//
//  XBConsole.swift
//  XBCheater
//
//  Created by Cory on 6/23/15.
//  Copyright (c) 2015 Bionware Technologies All rights reserved.
//

import Foundation

class XBConsole : NSObject {
  private var ip: String?
  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?
  var activeConnection = false
  
  init(ip: String) {
    self.ip = ip
  }
  
  func send(data: String) -> Bool {
    if activeConnection {
      let data: NSData = data.dataUsingEncoding(NSASCIIStringEncoding)!
      outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
      return true
    } else {
      return false
    }
  }
  
  func recv(len: Int) -> [UInt8] {
    if activeConnection {
      let bufferSize = len
      var inputBuffer = [UInt8](count:bufferSize, repeatedValue: 0)
      let bytesRead = inputStream!.read(&inputBuffer, maxLength: bufferSize)
      if bytesRead != -1 {
        return Array(inputBuffer[0...bytesRead])
      }
    }
    return [UInt8]()
  }
  
  func connect() -> Bool {
    NSStream.getStreamsToHostWithName(ip!, port: 730, inputStream: &inputStream, outputStream: &outputStream)
    if inputStream != nil && outputStream != nil {
      activeConnection = true
      inputStream!.open()
      outputStream!.open()
      let data = recv(1024)
      let connectionString = hexToAscii(Array(data[0...2]))!
      if connectionString == "201" { // "201- connected"
        return true
      }
    }
    println("[XBConsole Warning] Failed to connect to the specified console");
    return false
  }
  
  func closeStreams() {
    inputStream!.close()
    outputStream!.close()
    activeConnection = false
  }
  
  func getMemory(address: Int, len: Int) -> [UInt8] {
    var returnValue = [UInt8]()
    var l_addr = NSString(format:"%2X", address)
    var l_len = NSString(format:"%X", len)
    
    if activeConnection {
      
      send("getmemex addr=0x\(l_addr) length=0x\(l_len)\r\n")
      let l_connectionBuffer = recv(1026)
      
      if l_connectionBuffer.count > 31 {
        returnValue += l_connectionBuffer[32...32+len-1]
      } else {
        let l_connectionString = hexToAscii(Array(l_connectionBuffer[0...2]))
        if l_connectionString == "203" {
          
          var l_rem = len % 1024
          for _ in 0..<len/1024 {
            var data = recv(1026)
            data.removeRange(Range<Int>(start:0,end:2))
            returnValue += data
          }
          
          if l_rem > 0 {
            var data = recv(1026)
            if data.count > 2 {
              data.removeRange(Range<Int>(start:0,end:2))
              returnValue += data
            }
          }
          
          returnValue.removeAtIndex(returnValue.count-1)
        } else {
          println("[GETMEMEX Error] - Potential Overflow: \(l_connectionBuffer)")
        }
      }
    }
    return returnValue
  }
  
  func setMemory(address: Int, buffer: Array<UInt8>) {
    var l_addr = NSString(format:"%2X", address)
    var data = hexFromBytes(buffer)
    if activeConnection {
      send("setmem addr=0x\(l_addr) data=0x\(data)\r\n")
      recv(1024)
    }
  }
}