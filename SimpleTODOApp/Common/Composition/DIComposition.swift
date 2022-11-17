//
//  DIComposition.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import Foundation

// MARK: - Storage
private struct StorageKey: InjectionKey {
    static var currentValue: Storage = StorageImpl(
        settingsStorage: SettingsKeyValueStorage(
            store: UserDefaults.standard
        )
    )
}

extension InjectedValue {
    var storage: Storage {
        get { Self[StorageKey.self] }
        set { Self[StorageKey.self] = newValue }
    }
}
