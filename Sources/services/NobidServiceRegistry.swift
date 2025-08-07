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

/// Simple service registry to avoid circular dependencies with logic-business
public final class NobidServiceRegistry {
    
    public static let shared = NobidServiceRegistry()
    
    private var _configurationContext: NobidConfigurationContext?
    private var _signerService: NobidSignerService?
    private var _paymentStatusService: PaymentStatusService?
    private var _paymentContext: NobidPaymentContext?
    
    private init() {}
    
    public func register(configurationContext: NobidConfigurationContext) {
        _configurationContext = configurationContext
    }
    
    public func register(signerService: NobidSignerService) {
        _signerService = signerService
    }
    
    public func register(paymentStatusService: PaymentStatusService) {
        _paymentStatusService = paymentStatusService
    }
    
    public func register(paymentContext: NobidPaymentContext) {
        _paymentContext = paymentContext
    }
    
    public var configurationContext: NobidConfigurationContext {
        if _configurationContext == nil {
            _configurationContext = NobidConfigurationContextImpl()
            NobidLogger.debug("[NobidServiceRegistry] Created new NobidConfigurationContext instance")
        }
        return _configurationContext!
    }
    
    public var signerService: NobidSignerService {
        if let service = _signerService {
            return service
        }
        // Create fallback
        do {
            let service = try NobidSignerServiceImpl()
            _signerService = service
            return service
        } catch {
            NobidLogger.error("[NobidServiceRegistry] Failed to create NobidSignerService: \(error)")
            fatalError("Failed to initialize NobidSignerService: \(error)")
        }
    }
    
    public var paymentStatusService: PaymentStatusService {
        if _paymentStatusService == nil {
            _paymentStatusService = PaymentStatusServiceImpl()
            NobidLogger.debug("[NobidServiceRegistry] Created new PaymentStatusService instance")
        }
        return _paymentStatusService!
    }
    
    public var paymentContext: NobidPaymentContext {
        if _paymentContext == nil {
            _paymentContext = NobidPaymentContext()
            NobidLogger.debug("[NobidServiceRegistry] Created new NobidPaymentContext instance")
        }
        return _paymentContext!
    }
}
