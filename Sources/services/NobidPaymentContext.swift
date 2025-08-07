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

/// Context object for payment flow state management
public final class NobidPaymentContext: Sendable {
    
    public var selectedMsctDocId: String? {
        didSet {
            NobidLogger.debug("[payment-MSCT] NobidPaymentContext.didSet: selectedMsctDocId=\(selectedMsctDocId ?? "NIL")")
        }
    }
    
    public var selectedDocIconUri: URL?
    public var selectedDocPaymentStatusUri: URL?
    public var selectedDocScheme: String?
    public var selectedDocPspUrl: URL?
    public var paymentTransaction: Any? // NobidPaymentTransaction
    { didSet {
        NobidLogger.debug("[payment-MSCT][paymentStatus][paymentTransaction] NobidPaymentContext.didSet: paymentTransaction=\(String(describing: paymentTransaction))")
    } }
    
    public var transactionData: [String]? {
        didSet {
            NobidLogger.debug("[transaction_data] NobidPaymentContext.didSet: transactionData=\(String(describing: transactionData))")
        }
    }
    
    public var isPaymentFlow: Bool { 
        self.transactionData != nil 
    }
    
    public var transactionDataHashes: [String]? {
        guard let transactionData else { return nil }
        return transactionData.compactMap { $0.data(using: .utf8)?.sha256().base64URLEncodedString() }
    }
    
    public init() {}
    
    /// Reset all payment-related state
    public func resetVPresentationState() {
        NobidLogger.debug("[transaction_data][payment-MSCT] NobidPaymentContext.resetVPresentationState()")
        self.selectedMsctDocId = nil
        self.selectedDocPaymentStatusUri = nil
        self.selectedDocScheme = nil
        self.selectedDocPspUrl = nil
        self.selectedDocIconUri = nil
        self.transactionData = nil
        self.paymentTransaction = nil
    }
}
