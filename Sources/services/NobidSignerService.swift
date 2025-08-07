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
import CryptoSwift
import Logging
@preconcurrency import JOSESwift

public enum NobidSignerError: Error, LocalizedError {
    case error(reason: String)
}

/// Protocol for Nobid signing operations
public protocol NobidSignerService: Sendable {
    var algorithm: SignatureAlgorithm { get }
    var privateKey: SecKey? { get }
    var publicKey: SecKey? { get }
    var signer: Signer? { get }
    
    func createJWS(payloadDict: [String: Any]) throws -> JWS
}

/// Implementation of NobidSignerService
public final class NobidSignerServiceImpl: NobidSignerService {
    
    public let algorithm: SignatureAlgorithm = .ES256
    public var privateKey: SecKey?
    public var publicKey: SecKey?
    public var signer: Signer?
    
    public init() throws {
        let privateKey: SecKey = try Self.generateECDHPrivateKey()
        let publicKey: SecKey = try Self.generateECDHPublicKey(from: privateKey)
        let signer = Signer(
            signatureAlgorithm: algorithm,
            key: privateKey
        )
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.signer = signer
    }
    
    public func createJWS(payloadDict: [String: Any]) throws -> JWS {
        
        guard let privateKey: SecKey = self.privateKey else {
            NobidLogger.error("Key should be created")
            throw NobidSignerError.error(reason: "Key should be created")
        }
        
        guard Self.isECPrivateKey(privateKey) else {
            NobidLogger.error("Key should be EC and private")
            throw NobidSignerError.error(reason: "Key should be EC and private")
        }
        
        guard algorithm.isNotMacAlgorithm else {
            NobidLogger.error("MAC not supported")
            throw NobidSignerError.error(reason: "MAC not supported")
        }
        
        guard let signer: Signer = self.signer else {
            NobidLogger.error("Signer should be created")
            throw NobidSignerError.error(reason: "Signer should be created")
        }

        let header: JWSHeader = JWSHeader(algorithm: algorithm)
        let payload: Payload = .init(try payloadDict.toThrowingJSONData())
        
        return try JWS(
            header: header,
            payload: payload,
            signer: signer
        )
    }
    
    public static func generateECDHPrivateKey() throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return privateKey
    }
    
    public static func generateECDHPublicKey(from privateKey: SecKey) throws -> SecKey {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(domain: "YourDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate public key"])
        }
        return publicKey
    }
    
    public static func isECPrivateKey(_ secKey: SecKey) -> Bool {
        guard let attributes = SecKeyCopyAttributes(secKey) as? [CFString: Any] else {
            return false
        }
        
        let isPrivateKey = (attributes[kSecAttrKeyClass] as? String) == (kSecAttrKeyClassPrivate as String)
        let isECKey = (attributes[kSecAttrKeyType] as? String) == (kSecAttrKeyTypeEC as String)
        
        return isPrivateKey && isECKey
    }
}
