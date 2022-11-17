//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation

protocol KeyValueStore {
    func setValue<V>(_ value: V, for key: StoreKey)
    func getValue<V>(for key: StoreKey) throws -> V
    func getValue<V>(for key: StoreKey, defaultValue: V) -> V
    func removeValue(by key: StoreKey)
}

enum KeyValueStoreError: Error {
    case valueNotFoundForKey(String)
    case invalidValue
}

public struct StoreKey: RawRepresentable, ExpressibleByStringInterpolation, Hashable {

    public var rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init(stringInterpolation: String) {
        self.rawValue = stringInterpolation
    }
}
