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
        var title: String
    }

    var listTitle: String
    var todo: [Todo]
    var done: [Todo]
}

struct TodosView: View {

    @StateObject var interactor: TodosInteractor

    @State var showEditTitleAlert: Bool = false

    var body: some View {
        List {
            if !interactor.state.todo.isEmpty {
                Section("Plan Todo") {
                    ForEach(interactor.state.todo, id: \.id) { element in
                        TodoView(
                            title: element.title,
                            doneAction: { interactor.toggleTodo(element.id) },
                            changeTitleAction: { interactor.changeTitle($0, for: element.id) }
                        )
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else { return }
                        interactor.deleteItem(by: interactor.state.todo[index].id)
                    }
                    .onMove { from, to in
                        guard let fromIndex = from.first else { return }
                        interactor.move(fromIndex: fromIndex, toIndex: to)
                    }
                }
            }


            if !interactor.state.done.isEmpty {
                Section("Done") {
                    ForEach(interactor.state.done, id: \.id) { element in
                        TodoDoneView(
                            title: element.title,
                            doneAction: { interactor.toggleTodo(element.id) }
                        )
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else { return }
                        interactor.deleteItem(by: interactor.state.done[index].id)
                    }
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .navigationTitle($interactor.state.listTitle)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    interactor.addTodo()
                } label: {
                    ImageKit.Todos.add.systemImage
                }
                .keyboardShortcut("n", modifiers: [.command])
            }

            #if os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditTitleAlert.toggle()
                } label: {
                    ImageKit.Todos.more.systemImage
                }
            }
            #endif
        }
        .sheet(isPresented: $showEditTitleAlert) {
            ChangeListTitleView(
                title: interactor.state.listTitle) {
                    showEditTitleAlert.toggle()
                } changeTitleAction: { title in
                    interactor.changeListTitle(title)
                }

        }

    }
}

private struct TodoView: View {

    @State var title: String
    var doneAction: () -> Void
    var changeTitleAction: (_ title: String) -> Void

    var body: some View {
        HStack {
            Button {
                doneAction()
            } label: {
                ImageKit.Todos.emptyMark.systemImage
            }
            .buttonStyle(.plain)

            TextField("Enter Todo", text: $title)
                .onChange(of: title) { newValue in
                    changeTitleAction(newValue)
                }
        }
    }
}

private struct TodoDoneView: View {
    var title: String
    var doneAction: () -> Void

    var body: some View {
        HStack {
            Button {
                doneAction()
            } label: {
                ImageKit.Todos.done.systemImage
            }
            .buttonStyle(.plain)

            if title.isEmpty {
                Text("Untitled todo")
                    .foregroundColor(.gray)
                    .strikethrough()
            } else {
                Text(title)
                    .foregroundColor(.gray)
                    .strikethrough()
            }
        }
    }
}

private struct ChangeListTitleView: View {
    @State var title: String
    var doneAction: () -> Void
    var changeTitleAction: (_ title: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Change list title")
                .font(.title2.weight(.semibold))
            TextField("Enter title", text: $title)
            HStack(spacing: 8
            ) {
                Spacer()
                Button("Cancel") {
                    doneAction()
                }
                Button("Done") {
                    doneAction()
                    changeTitleAction(title)
                }
            }
        }
        .frame(minWidth: 520)
        .padding(16)
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
        func move(fromIndex: Int, toIndex: Int) {}
        func changeTitle(_ title: String, for todoId: UUID) {}
        func changeDoneStatus(_ id: UUID) {}

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
                        TodoModel(id: UUID(), title: "", isDone: false),
//                        TodoModel(id: UUID(), title: "2", isDone: true),
//                        TodoModel(id: UUID(), title: "2", isDone: true)
                    ],
                    listTitle: "List"
                )
            )
        )
    }
}
