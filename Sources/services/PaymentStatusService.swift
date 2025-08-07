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

public enum PaymentStatusCode: String, Codable, Sendable {
    case unknown = "UNKN"   //     Server returned an unknown status code
    case received = "RCVD"   //     The payment has been received and is awaiting Strong Customer Authentication
    case acceptedCustomerProfile = "ACCP"   //     The preceding check of technical validation was successful. The customer profile check was also successful.
    case acceptedSettlementInProgress = "ACSP"   //      The payment has been sent by the bank but is not yet settled in the creditor account.
    case acceptedSettlementCompleted = "ACSC"   //      The payment has been sent by the bank and settled in the creditor's account.
    case notAuthorized = "NAUT"   //     The end-user has cancelled the payment authorization
    case rejected = "RJCT"   //     The payment has failed due to insufficient funds in the debtor's account
    case pending = "PDNG"   //     The debtor account holder has edited the payment in their online banking and a new Strong Customer Authentication is now pending
    case cancelled = "CANC"   //     The payment has been deleted by the end-user
    case onHold = "PRSY"   //     The payment initiation was put on hold by the bank
    case partiallyAccepted = "PATC"   //      The payment requires a second authorization
}

public struct PaymentStatusResponseObject: Codable {
  public let statusCode: String
  public enum CodingKeys: String, CodingKey {
    case statusCode = "status-code"
  }
}

public protocol PaymentStatusService: Sendable {
    func retrieveStatus(url: URL) async -> PaymentStatusCode
}

public final class PaymentStatusServiceImpl: PaymentStatusService, @unchecked Sendable {
    
    public init() {}
    
    public func retrieveStatus(url: URL) async -> PaymentStatusCode {
        let fetcher: NobidFetcher<PaymentStatusResponseObject> = NobidFetcher()
        let response = await fetcher.fetch(url: url)
        switch response {
        case .success(let status):
            return PaymentStatusCode(rawValue: status.statusCode) ?? .unknown
        case .failure:
            return .unknown
        }
    }
}
