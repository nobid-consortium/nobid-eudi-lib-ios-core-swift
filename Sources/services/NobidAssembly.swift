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
import Swinject

public final class NobidAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        // Configuration context - register with both DI and NobidServiceRegistry
        container.register(NobidConfigurationContext.self) { _ in
            let configurationContext = NobidConfigurationContextImpl()
            NobidServiceRegistry.shared.register(configurationContext: configurationContext)
            return configurationContext
        }
        .inObjectScope(.container)
        
        // Signer service - register with both DI and NobidServiceRegistry
        container.register(NobidSignerService.self) { _ in
            do {
                let signerService = try NobidSignerServiceImpl()
                NobidServiceRegistry.shared.register(signerService: signerService)
                return signerService
            } catch {
                NobidLogger.error("[NobidCustomizations-SEC] FAILED to create NobidSignerService: error=\(error)")
                fatalError("Failed to initialize NobidSignerService: \(error)")
            }
        }
        .inObjectScope(.container)
        
        // Payment status service - register with both DI and NobidServiceRegistry
        container.register(PaymentStatusService.self) { _ in
            let paymentStatusService = PaymentStatusServiceImpl()
            NobidServiceRegistry.shared.register(paymentStatusService: paymentStatusService)
            return paymentStatusService
        }
        .inObjectScope(.container)
        
        // Payment context is session-scoped, shared across presentation flow
        // Register the same instance with both DI container and NobidServiceRegistry for compatibility
        container.register(NobidPaymentContext.self) { _ in
            let paymentContext = NobidPaymentContext()
            NobidServiceRegistry.shared.register(paymentContext: paymentContext)
            return paymentContext
        }
        .inObjectScope(.container)  // Singleton within container scope
    }
}
