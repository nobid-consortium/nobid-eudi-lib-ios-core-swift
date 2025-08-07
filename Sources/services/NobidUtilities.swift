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

/// Stateless utility functions for Nobid operations
/// These functions do not maintain any state and are provided as static methods
public final class NobidUtilities {
    
    private init() {} // Prevent instantiation
    
    public static func isMsctQrCode(string: String) -> Bool {
        return string.lowercased().hasPrefix("https://") || string.lowercased().hasPrefix("http://")
    }
    
    public static func createVpUrl(string: String) -> URL? {
        if (string.lowercased().hasPrefix("https://") || string.lowercased().hasPrefix("http://")) {
            NobidLogger.taskSucceed("[a2pay] case: MSCT flow identified by qrCode")
            guard let urlEncoded = string.urlEncoded else {
                NobidLogger.error("[a2pay] createVpUrl: FAILED encoding URL")
                return nil
            }
            let retVal = URL(string: "msct://?payload=\(urlEncoded)")
            NobidLogger.debug("[a2pay] createVpUrl: new MSCT url with qrCode as encoded payload=\(String(describing: retVal))")
            return retVal
        }
        return URL(string: string)
    }
    
    public static func extractMsctPayload(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            NobidLogger.error("[a2pay] extractMsctPayload: FAILED resolving URL components")
            return nil
        }
        guard let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value else {
            NobidLogger.error("[a2pay] extractMsctPayload: FAILED extracting payload")
            return nil
        }
        guard let payloadDecoded = payload.urlDecoded else {
            NobidLogger.error("[a2pay] extractMsctPayload: FAILED decoding payload")
            return nil
        }
        NobidLogger.debug("[a2pay] extractMsctPayload: originalUrl=\(url); extracted payload=\(payloadDecoded)")
        return payloadDecoded
    }
    
    public static func titlelized(_ str: String) -> String {
        let replaced = str.replacingOccurrences(of: "_", with: " ")
        return replaced.capitalized
    }
    
    public static func transactionDataFirstAsA2Pay(from transactionData: [String]?) -> TransactionDataA2Pay? {
        guard let transactionDataBase64 = transactionData?.first else {
            NobidLogger.error("[transaction_data] transactionDataAsRequestDataUI: empty or nil")
            return nil 
        }
        guard let transactionDataJson = transactionDataBase64.base64URLDecode else {
            NobidLogger.error("[transaction_data] transactionDataAsRequestDataUI: Error decoding transactionDataBase64")
            return nil 
        }
        guard let transactionDataData = transactionDataJson.data(using: .utf8) else {
            NobidLogger.error("[transaction_data] transactionDataAsRequestDataUI: Error decoding as data")
            return nil 
        }
        
        do {
            let decoder = JSONDecoder()
            let obj = try decoder.decode(TransactionDataA2Pay.self, from: transactionDataData)
            NobidLogger.debug("[transaction_data] transactionDataAsRequestDataUI: decoded")
            return obj
        } catch {
            NobidLogger.error("[transaction_data] Transaction Data: Error decoding transactionDataJson: \(error)")
            return nil
        }
    }
    
    public static func transactionDataAsRequestDataUI(from transactionData: [String]?) -> [(id: String, isSelected: Bool, title: String, value: String)]? {
        guard let obj = transactionDataFirstAsA2Pay(from: transactionData) else {
            NobidLogger.error("[transaction_data] transactionDataFirstAsA2Pay FAILED")
            return nil
        }
        
        var requestDataRows: [(id: String, isSelected: Bool, title: String, value: String)] = []
        
        if let str = obj.instructed_amount {
            requestDataRows.append(
                (id: "3", isSelected: true, title: titlelized("instructed_amount"), value: String(str))
            )
        }
        
        if let str = obj.currency {
            requestDataRows.append(
                (id: "4", isSelected: true, title: titlelized("currency"), value: String(str))
            )
        }
        
        if let str = obj.creditor_name {
            requestDataRows.append(
                (id: "5", isSelected: true, title: titlelized("creditor_name"), value: String(str))
            )
        }
        
        if let str = obj.purpose {
            requestDataRows.append(
                (id: "6", isSelected: true, title: titlelized("purpose"), value: String(str))
            )
        }
        
        NobidLogger.debug("[transaction_data] transactionDataAsRequestDataUI: EXIT")
        return requestDataRows
    }
}
