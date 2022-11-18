//  Copyright © 2022 Chipp Studio OÜ. All rights reserved.

import Foundation
import CoreData
import Combine

protocol Storage {
    var context: NSManagedObjectContext { get }
    func saveContext()
    func reloadContainer()
}

final class StorageImpl: Storage {

    private let settingsStorage: SettingsKeyValueStorage

    private var iCloudEnabled: Bool = false

    private var cancellable: [AnyCancellable] = []

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(
        settingsStorage: SettingsKeyValueStorage
    ) {
        self.settingsStorage = settingsStorage
    }

    func reloadContainer() {
        saveContext()
        if iCloudEnabled != settingsStorage.iCloudSyncEnable {
            persistentContainer = setupContainer()
        }
    }

    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        setupContainer()
    }()

    private func setupContainer() -> NSPersistentContainer {
        iCloudEnabled = settingsStorage.iCloudSyncEnable
        let container: NSPersistentContainer
        if iCloudEnabled {
            container = NSPersistentCloudKitContainer(name: "SimpleTODOApp")
        } else {
            container = NSPersistentContainer(name: "SimpleTODOApp")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

        let description = NSPersistentStoreDescription()
        description.url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("SimpleTODOAppSQL")
        description.type = NSSQLiteStoreType

        if iCloudEnabled {
            let iCloudID = iCloudID // Use your iCloud ID
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudID)
            description.cloudKitContainerOptions = options
        }

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                print("Load persistent stores with: \(error), source: Storage")
            }
        })
        return container
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError

                
                print(
                    "Unresolved error \(nserror), context - \(nserror.userInfo), source: Storage"
                )
            }
        }
    }
}
