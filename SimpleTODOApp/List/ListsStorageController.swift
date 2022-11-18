//
//  ListsStorageController.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import Foundation
import CoreData
import Combine

struct TodoListModel {
    let id: UUID
    let title: String
}

protocol ListsStorageController {
    var lists: AnyPublisher<[TodoListModel], Never> { get }
    func fetch()
    func addList()
    func move(fromIndex: Int, toIndex: Int)
    func deleteList(id: UUID)
}

final class ListsStorageControllerImpl: NSObject, ListsStorageController {
    
    
    var lists: AnyPublisher<[TodoListModel], Never> {
        $listsModel.eraseToAnyPublisher()
    }
    
    @Injected(\.storage) private var storage
    
    private var listsResultController: NSFetchedResultsController<TodoList>?
    private var listsObjects: [TodoList] = [] {
        didSet {
            let newLists = listsObjects.map(\.model)
            listsModel = newLists
        }
    }
    @Published private var listsModel: [TodoListModel] = []
    
    func addList() {
        let list = TodoList(context: storage.context)
        list.title = "Default List"
        list.id = UUID()
        list.displayOrder = Int16(listsObjects.count) * storageDisplayOrderOffset
        
        storage.context.insert(list)
        
        storage.saveContext()
    }

    func move(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex else { return }

        listsObjects.move(fromOffsets: [fromIndex], toOffset: toIndex)

        listsObjects.enumerated().forEach {
            $0.element.displayOrder = Int16($0.offset) * storageDisplayOrderOffset
        }
        storage.saveContext()
    }
    
    func deleteList(id: UUID) {
        guard let list = listsObjects.first(where: { $0.id == id}) else { return }
        storage.context.delete(list)
    }
    
    func fetch() {
        guard listsResultController == nil else { return}
        
        let request = TodoList.fetchRequest()
        
        // Here we can use custom sort descriptions for lists
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        
        listsResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: storage.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        listsResultController?.delegate = self
        
        do {
            try listsResultController?.performFetch()
            guard let fetchedObjects = listsResultController?.fetchedObjects else { return }
            listsObjects = fetchedObjects
        } catch {
            let nserror = error as NSError
            print(
                "Unresolved error \(nserror), context - \(nserror.userInfo), source: LanguageController"
            )
        }
    }
}

extension ListsStorageControllerImpl: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        listsObjects = fetchedObjects
            .compactMap {
                $0 as? TodoList
            }
    }
}

private extension TodoList {
    var model: TodoListModel {
        TodoListModel(
            id: id ?? UUID(),
            title: title ?? "Undefined title"
        )
    }
}
