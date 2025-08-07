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


public struct NobidDocumentMetadata: Sendable {
    public var backgroundImageUrl: URL?
    public var backgroundImage: Image? // <C> used for hardcoded background images
    public var backgroundColor: Color?
    public var logoUrl: URL?
    public var textColor: Color?
    
    public init(backgroundImageUrl: URL? = nil, backgroundImage: Image? = nil, backgroundColor: Color? = nil, logoUrl: URL? = nil, textColor: Color? = nil) {
        self.backgroundImageUrl = backgroundImageUrl
        self.backgroundImage = backgroundImage
        self.backgroundColor = backgroundColor
        self.logoUrl = logoUrl
        self.textColor = textColor
    }
}
