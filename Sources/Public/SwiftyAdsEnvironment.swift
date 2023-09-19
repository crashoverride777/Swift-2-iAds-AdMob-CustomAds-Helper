//    The MIT License (MIT)
//
//    Copyright (c) 2015-2023 Dominik Ringler
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import UserMessagingPlatform

public enum SwiftyAdsEnvironment {
    case production
    case development(testDeviceIdentifiers: [String], consentConfiguration: ConsentConfiguration)

    public enum ConsentConfiguration {
        public typealias Geography = UMPDebugGeography

        // Default consent settings
        case `default`(geography: Geography)
        // Resets consent info every time app is launched
        case resetOnLaunch(geography: Geography)

        public var geography: Geography {
            switch self {
            case .default(let geography), .resetOnLaunch(let geography):
                return geography
            }
        }
    }
}
