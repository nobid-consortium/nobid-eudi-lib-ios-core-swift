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

public struct TransactionDataA2Pay: Codable {
    public let payment_id: String?
    public let creditor_account: [String: String]?
    public let instructed_amount: String?
    public let currency: String?
    public let creditor_name: String?
    public let creditor_logo: URL?
    public let purpose: String?
    public let type: String?
    public let credential_ids: [String]?
    public let transaction_data_hashes_alg: [String]?
}
