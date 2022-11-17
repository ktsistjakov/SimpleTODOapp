//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation

struct InjectedValue {
    private static var current = InjectedValue()

    static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<InjectedValue, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
