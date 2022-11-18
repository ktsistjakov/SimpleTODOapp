//
//  ListView.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI
import Combine

struct ListsViewState: Hashable {
    struct List: Hashable {
        let id: UUID
        let title: String
    }
    
    var lists: [List]
    var enableiCloudSync: Bool
}

struct ListsView: View {
    
    @StateObject var interactor: ListsInteractor
    
    var body: some View {
        VStack {
            List {
                ForEach(interactor.state.lists, id: \.self) { list in
                    NavigationLink {
                        TodosView(
                            interactor: TodosInteractor(
                                todoStorageController: TodosStorageControllerImpl(listId: list.id)
                            )
                        )
                    } label: {
                        Text(list.title)
                    }
                    .contextMenu {
                        Button {
                            interactor.deleteList(id: list.id)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    interactor.deleteList(id: interactor.state.lists[index].id)
                }
                .onMove { from, to in
                    guard let fromIndex = from.first else { return }
                    interactor.move(fromIndex: fromIndex, toIndex: to)
                }
            }
            #if os(macOS)
            Toggle("Enable iCloud sync", isOn: $interactor.state.enableiCloudSync)
                .padding()
            #endif
        }
        .navigationTitle("Lists")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    interactor.addList()
                } label: {
                    ImageKit.Lists.add.systemImage
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Toggle("Enable iCloud sync", isOn: $interactor.state.enableiCloudSync)
            }
            #endif
        }
    }
}

struct ListView_Previews: PreviewProvider {
    private class ListsStorageControllerPreviewImpl: ListsStorageController {
        @Published var model: [TodoListModel]
        var lists: AnyPublisher<[TodoListModel], Never> {
            $model.eraseToAnyPublisher()
        }
        func refetch() {}
        func fetch() {}
        func addList() {}
        func move(fromIndex: Int, toIndex: Int) {}
        func deleteList(id: UUID) {}
        
        init(model: [TodoListModel]) {
            self.model = model
        }
    }
    static var previews: some View {
        ListsView(
            interactor: ListsInteractor(
                listsStorageController: ListsStorageControllerPreviewImpl(
                    model: [
                        TodoListModel(id: UUID(), title: "First list"),
                        TodoListModel(id: UUID(), title: "Second list"),
                    ]
                ), settingsKeyValueStorage: SettingsKeyValueStorage(store: UserDefaults.standard)
            )
        )
    }
}
