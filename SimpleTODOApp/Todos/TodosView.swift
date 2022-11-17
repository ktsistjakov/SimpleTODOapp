//
//  TodosView.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI
import Combine

struct TodosViewState {
    struct Todo {
        let id: UUID
        let title: String
    }

    var listTitle: String
    var todo: [Todo]
    var done: [Todo]
}

struct TodosView: View {

    @StateObject var interactor: TodosInteractor

    var body: some View {
        List {
            Section("Plan Todo") {
                Text("sdfh")
            }

            Section("Done") {
                Text("sdfhghjh")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle($interactor.state.listTitle)
    }
}

struct TodosView_Previews: PreviewProvider {
    private class TodosStorageControllerPreviewImpl: TodosStorageController {
        @Published var model: [TodoModel]
        var todos: AnyPublisher<[TodoModel], Never> {
            $model.eraseToAnyPublisher()
        }

        let listTitle: String
        func changeListTitle(_ title: String) {}
        func addTodo() {}
        func deleteTodo(_ id: UUID) {}
        func changeTitle(_ title: String, for todoId: UUID) {}

        init(model: [TodoModel], listTitle: String) {
            self.model = model
            self.listTitle = listTitle
        }
    }
    static var previews: some View {
        TodosView(
            interactor: TodosInteractor(
                todoStorageController: TodosStorageControllerPreviewImpl(
                    model: [
                        TodoModel(id: UUID(), title: "1", isDone: false),
                        TodoModel(id: UUID(), title: "2", isDone: true)
                    ],
                    listTitle: "List"
                )
            )
        )
    }
}
