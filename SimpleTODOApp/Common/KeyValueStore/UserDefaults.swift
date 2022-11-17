//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation

extension UserDefaults: KeyValueStore {
    func setValue<V>(_ value: V, for key: StoreKey) {
        set(value, forKey: key.rawValue)
    }

    func getValue<V>(for key: StoreKey) throws -> V {
        guard let value = object(forKey: key.rawValue) as? V else {
            throw KeyValueStoreError.valueNotFoundForKey(key.rawValue)
        }
        return value
    }

    func getValue<V>(for key: StoreKey, defaultValue: V) -> V {
        guard let value = object(forKey: key.rawValue) as? V else {
            return defaultValue
        }
        return value
    }

    func removeValue(by key: StoreKey) {
        removeObject(forKey: key.rawValue)
    }
}
