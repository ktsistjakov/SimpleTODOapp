//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation
import Combine

struct SettingsKeyValueStorage {
    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }

    var iCloudSyncEnable: Bool {
        get { store.getValue(for: .iCloud, defaultValue: false) }
        set { store.setValue(newValue, for: .iCloud) }
    }
}

private extension StoreKey {
    static let iCloud: Self = "iCloud_isEnable_to_sync"
}
