//
//  ListsInteractor.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import Foundation
import Combine

final class ListsInteractor: ObservableObject {
    
    @Published var state: ListsViewState
    @Injected(\.storage) private var storage
    
    private let listsStorageController: ListsStorageController
    private var settingsKeyValueStorage: SettingsKeyValueStorage
    
    private var cancellable: [AnyCancellable] = []
    
    init(
        listsStorageController: ListsStorageController,
        settingsKeyValueStorage: SettingsKeyValueStorage
    ) {
        self.state = ListsViewState(
            lists: [],
            enableiCloudSync: settingsKeyValueStorage.iCloudSyncEnable
        )
        self.settingsKeyValueStorage = settingsKeyValueStorage
        self.listsStorageController = listsStorageController
        
        fetchAndSubscribe()
        subscribe()
    }
    
    func openList(id: UUID) {
        print("Open List")
    }
    
    func addList() {
        listsStorageController.addList()
    }
    
    func deleteList(id: UUID) {
        listsStorageController.deleteList(id: id)
    }

    func move(fromIndex: Int, toIndex: Int) {
        listsStorageController.move(fromIndex: fromIndex, toIndex: toIndex)
    }

    private func subscribe() {
        $state
            .receive(on: DispatchQueue.main)
            .map(\.enableiCloudSync)
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.settingsKeyValueStorage.iCloudSyncEnable = newValue
                self?.storage.reloadContainer()
            }
            .store(in: &cancellable)
    }
    
    private func fetchAndSubscribe() {
        listsStorageController.lists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lists in
                let newLists = lists.map {
                    ListsViewState.List(
                        id: $0.id,
                        title: $0.title
                    )
                }
                
                self?.state.lists = newLists
            }
            .store(in: &cancellable)
        
        listsStorageController.fetch()
    }
}
