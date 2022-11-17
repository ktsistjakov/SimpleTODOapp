//
//  ListView.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI
import Combine

struct ListsViewState {
    struct List {
        let id: UUID
        let title: String
    }
    
    var lists: [List]
}

struct ListsView: View {
    
    @StateObject var interactor: ListsInteractor
    
    var body: some View {
        List {
            ForEach(interactor.state.lists, id: \.id) { list in
                NavigationLink {
                    TodosView(
                        interactor: TodosInteractor(
                            todoStorageController: TodosStorageControllerImpl(listId: list.id)
                        )
                    )
                } label: {
                    Text(list.title)
                }
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                interactor.deleteList(id: interactor.state.lists[index].id)
            }
        }
        .navigationTitle("Lists")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    interactor.addList()
                } label: {
                    ImageKit.Lists.add.systemImage
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    private class ListsStorageControllerPreviewImpl: ListsStorageController {
        @Published var model: [TodoListModel]
        var lists: AnyPublisher<[TodoListModel], Never> {
            $model.eraseToAnyPublisher()
        }
        func fetch() {}
        func addList() {}
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
                )
            )
        )
    }
}
