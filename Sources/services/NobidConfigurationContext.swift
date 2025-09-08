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

/// Protocol for Nobid-specific configuration management  
/// Made class-constrained to support ObjectIdentifier usage for debugging
public protocol NobidConfigurationContext: Sendable, AnyObject {
    var issuer: NobidIssuer { get set }
    var isIPSZIssuerUrl: Bool { get set }
    var isIssuanceFlowChooseFromListVariant: Bool { get set }
    var isIPSZflow: Bool { get }
}

/// Implementation of NobidConfigurationContext
public final class NobidConfigurationContextImpl: NobidConfigurationContext {
    
    public var issuer: NobidIssuer = .nobidIssuerPosteItaliane
    public var isIPSZIssuerUrl: Bool = false
    public var isIssuanceFlowChooseFromListVariant: Bool = false
    
    public var isIPSZflow: Bool {
        let retVal = self.isIPSZIssuerUrl && self.isIssuanceFlowChooseFromListVariant
        NobidLogger.debug("[IPSZ] isIPSZflow=\(retVal); isIPSZIssuerUrl=\(self.isIPSZIssuerUrl); isIssuanceFlowChooseFromListVariant=\(self.isIssuanceFlowChooseFromListVariant); service=\(ObjectIdentifier(self))")
        // Additional detailed logging for diagnosis
        if !retVal {
            if !self.isIPSZIssuerUrl {
                NobidLogger.debug("[IPSZ] IPSZ flow DISABLED: isIPSZIssuerUrl=false (issuer URL doesn't contain 'nobid-wallet-it-pid-provider.it')")
            }
            if !self.isIssuanceFlowChooseFromListVariant {
                NobidLogger.debug("[IPSZ] IPSZ flow DISABLED: isIssuanceFlowChooseFromListVariant=false (not set during issuance flow)")
            }
        }
        return retVal
    }
    
    public init() {}
}
