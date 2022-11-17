//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation

@propertyWrapper
struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValue, T>
    var wrappedValue: T {
        get { InjectedValue[keyPath] }
        set { InjectedValue[keyPath] = newValue }
    }

    init(_ keyPath: WritableKeyPath<InjectedValue, T>) {
        self.keyPath = keyPath
    }
}
