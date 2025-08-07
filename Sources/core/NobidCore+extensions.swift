/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import Foundation
import SwiftUI
import CryptoSwift
import Logging
import JOSESwift

public extension String {
    var nobidBase64UrlDecodedString: String? {
        return self.base64URLDecode
    }
    
    var nobidBase64DecodedString: String? {
      if let data = Data(base64Encoded: self) {
        return String(data: data, encoding: .utf8)
      }
      return nil
    }
}

internal extension String {
    
    var urlEncoded: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    var urlDecoded: String? {
        self.removingPercentEncoding
    }

    var base64URLDecode: String? {
      var base64 = self
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

      // Padding the string with '=' characters to make its length a multiple of 4
      let paddingLength = 4 - base64.count % 4
      if paddingLength < 4 {
        base64.append(contentsOf: String(repeating: "=", count: paddingLength))
      }

      if let data = Data(base64Encoded: base64) {
        return String(data: data, encoding: .utf8)
      }

      return nil
    }
}

internal extension Data {
  // Encodes the data as a base64 URL-safe string
  func base64URLEncodedString() -> String {
    var base64String = self.base64EncodedString()
    base64String = base64String.replacingOccurrences(of: "/", with: "_")
    base64String = base64String.replacingOccurrences(of: "+", with: "-")
    base64String = base64String.replacingOccurrences(of: "=", with: "")
    return base64String
  }
}


internal extension Dictionary where Key == String, Value == Any {
    func toThrowingJSONData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
}


internal extension SignatureAlgorithm {
  var isNotMacAlgorithm: Bool {
    switch self {
    case .HS256, .HS384, .HS512:
      return false  // These are HMAC algorithms
    default:
      return true   // All other algorithms are not MAC-based
    }
  }
}

extension Data {
    func prettyPrintedJSONString() -> String? {
//return String(data: self, encoding: .utf8)
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as: UTF8.self)
        } else {
            return nil
        }
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(hexString: String, alpha: Double = 1) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        self.init(hex: UInt(hex, radix: 16) ?? 0, alpha: alpha)
    }
}

