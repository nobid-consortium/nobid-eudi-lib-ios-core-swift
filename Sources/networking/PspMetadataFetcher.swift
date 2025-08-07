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

public struct PspMetadataResponse: Codable {
    public let schemes: [String: MsctMetaDataObject]
}

public struct MsctMetaDataObject: Codable {
    public let name: String
    public let paymentStatusUri: URL?
    public let msctUri: URL?

    enum CodingKeys: String, CodingKey {
        case name
        case paymentStatusUri = "payment_status_uri"
        case msctUri = "msct_uri"
    }
}

public class PspMetadataFetcher {
    public static func fetchPspMetadata(pspUrl: URL) async -> PspMetadataResponse? {
        NobidLogger.taskSucceed("[paymentStatus][payment-MSCT] fetchPspMetadata request CREATED: pspUrl=\(pspUrl)")
        let fetcher: NobidFetcher<PspMetadataResponse> = NobidFetcher()
        let result = await fetcher.fetch(url: pspUrl)
        switch result {
        case .success(let pspMetadataResponse):
            NobidLogger.taskSucceed("[paymentStatus][payment-MSCT] fetchPspMetadata response ENCODED")
            NobidLogger.dump("[paymentStatus][payment-MSCT] VP: fetchPspMetadata: pspMetadataResponse=\(pspMetadataResponse)")
            return pspMetadataResponse
        case .failure(let error):
            NobidLogger.taskFailed("[paymentStatus][payment-MSCT] fetchPspMetadata response FAILED: error=\(error)")
            return nil
        }
    }
    
    public static func fetchPaymentStatusUri(pspUrl: URL, scheme: String) async -> URL? {
        let pspMetadataResponse = await fetchPspMetadata(pspUrl: pspUrl)
        let retVal = pspMetadataResponse?.schemes[scheme]?.paymentStatusUri
        if retVal != nil {
            NobidLogger.debug("[paymentStatus] fetchPaymentStatusUri: scheme=\(scheme); paymentStatusUri=\(retVal?.absoluteString ?? "nil")")
        }
        else {
            NobidLogger.error("[paymentStatus] fetchPaymentStatusUri: scheme=\(scheme); paymentStatusUri NOT FOUND")
        }
        return retVal
    }
}
