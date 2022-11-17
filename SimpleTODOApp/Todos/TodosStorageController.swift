//
//  TodosStorageController.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import Foundation
import CoreData
import Combine

struct TodoModel {
    let id: UUID
    let title: String
    let isDone: Bool
}

protocol TodosStorageController {
    var todos: AnyPublisher<[TodoModel], Never> { get }
    var listTitle: String { get }
    func changeListTitle(_ title: String)
    func addTodo()
    func deleteTodo(_ id: UUID)
    func changeTitle(_ title: String, for todoId: UUID)
    func changeDoneStatus(_ id: UUID)
}

final class TodosStorageControllerImpl: NSObject, TodosStorageController {

    var todos: AnyPublisher<[TodoModel], Never> {
        $todosModel.eraseToAnyPublisher()
    }

    var listTitle: String {
        listObject?.title ?? "Untitled list"
    }

    @Injected(\.storage) private var storage: Storage
    private var todosFetchResultController: NSFetchedResultsController<Todo>?
    private var listObject: TodoList?
    private var todosObject: [Todo] = [] {
        didSet {
            todosModel = todosObject.map(\.model)
        }
    }

    @Published private var todosModel: [TodoModel] = []


    init(listId: UUID) {
        super.init()

        fetchListBy(id: listId)
        fetchTodosFor(listId: listId)
    }

    func changeListTitle(_ title: String) {
        guard let listObject else { return }

        listObject.title = title

        storage.saveContext()
    }

    func addTodo() {
        guard let listObject else { return }
        let todo = Todo(context: storage.context)
        todo.isDone = false
        todo.id = UUID()
        todo.title = ""

        listObject.addToTodos(todo)

        storage.saveContext()

    }

    func deleteTodo(_ id: UUID) {
        guard
            let listObject,
            let todo = todosObject.first(where: { $0.id == id })
        else { return }

        listObject.removeFromTodos(todo)

        storage.saveContext()
    }

    func changeTitle(_ title: String, for todoId: UUID) {
        guard let todo = todosObject.first(where: { $0.id == todoId }) else { return }

        todo.title = title

        storage.saveContext()
    }

    func changeDoneStatus(_ id: UUID) {
        guard let todo = todosObject.first(where: { $0.id == id }) else { return }

        todo.isDone.toggle()

        storage.saveContext()
    }

    private func fetchListBy(id: UUID) {
        let request = TodoList.fetchRequest()
        request.predicate = NSPredicate(format: "id=%@", id as CVarArg)

        do {
            listObject = try storage.context.fetch(request).first
        } catch {
            let nserror = error as NSError
            print(
                "Unresolved error \(nserror), context - \(nserror.userInfo), source: LanguageController"
            )
        }
    }

    private func fetchTodosFor(listId: UUID) {
        guard todosFetchResultController == nil else { return }

        let request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "list.id=%@", listId as CVarArg)

        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: false)]

        todosFetchResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: storage.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        todosFetchResultController?.delegate = self

        do {
            try todosFetchResultController?.performFetch()
            guard let fetchObjects = todosFetchResultController?.fetchedObjects else { return }
            todosObject = fetchObjects
        } catch {
            let nserror = error as NSError
            print(
                "Unresolved error \(nserror), context - \(nserror.userInfo), source: LanguageController"
            )
        }
    }
}

extension TodosStorageControllerImpl: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        todosObject = fetchedObjects.compactMap {
            $0 as? Todo
        }
    }
}

private extension Todo {
    var model: TodoModel {
        TodoModel(
            id: id ?? UUID(),
            title: title ?? "Unnamed TODO",
            isDone: isDone
        )
    }
}
