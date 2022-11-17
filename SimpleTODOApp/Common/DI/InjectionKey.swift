//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation

protocol InjectionKey {
    associatedtype Value

    static var currentValue: Self.Value { get set}
}
