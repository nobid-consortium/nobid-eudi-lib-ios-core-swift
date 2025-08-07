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
import SwiftUI

public struct NobidHeader: View {
    public init() {       
    }
    public var body: some View {
        if #available(iOS 15.0, *) {
            HStack {
                Image("nobid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                Spacer()
            }
            .background {
                Rectangle()
                    .fill(Color(hex: 0x5A78B7))
            }
            .overlay(alignment: .top) {
                Color(hex: 0x5A78B7)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
            }
        } else {
            // Fallback on earlier versions
            // <C> iOS 14 compatibility is her due to other modules having iOS 14 as a minimum requirement
            // We are fine with the simple fallback becuase real app will always be iOS 15+
            HStack {
                Image("nobid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                Spacer()
            }
        }
    }
}
