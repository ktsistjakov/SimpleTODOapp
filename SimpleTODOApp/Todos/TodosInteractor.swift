//
//  TodosInteractor.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import Foundation
import Combine

final class TodosInteractor: ObservableObject {

    @Published var state: TodosViewState

    private let todoStorageController: TodosStorageController

    private var cancellable: [AnyCancellable] = []

    init(todoStorageController: TodosStorageController) {
        self.todoStorageController = todoStorageController
        self.state = TodosViewState(
            listTitle: todoStorageController.listTitle,
            todo: [],
            done: []
        )

        fetchAndSubscription()
        subscribe()
    }

    private func subscribe() {
        $state
            .receive(on: DispatchQueue.main)
            .map(\.listTitle)
            .removeDuplicates()
            .sink { [weak self] title in
                self?.todoStorageController.changeListTitle(title)
            }
            .store(in: &cancellable)
    }

    private func fetchAndSubscription() {
        todoStorageController.todos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                var done: [TodosViewState.Todo] = []
                var todo: [TodosViewState.Todo] = []

                todos.forEach {
                    if $0.isDone {
                        done.append(
                            TodosViewState.Todo(
                                id: $0.id,
                                title: $0.title
                            )
                        )
                    } else {
                        todo.append(
                            TodosViewState.Todo(
                                id: $0.id,
                                title: $0.title
                            )
                        )
                    }
                }

                self?.state.done = done
                self?.state.todo = todo
            }
            .store(in: &cancellable)
    }
}
