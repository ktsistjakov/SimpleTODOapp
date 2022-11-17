//
//  ListRootView.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI

struct ListsRootView: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif

    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationStack {
                ListsView(
                    interactor: ListsInteractor(
                        listsStorageController: ListsStorageControllerImpl()
                    )
                )
            }
        } else {
            NavigationSplitView {
                ListsView(
                    interactor: ListsInteractor(
                        listsStorageController: ListsStorageControllerImpl()
                    )
                )
            } detail: {
                Text("Select list")
            }
        }
#else
        NavigationSplitView {
            ListsView(
                interactor: ListsInteractor(
                    listsStorageController: ListsStorageControllerImpl()
                )
            )
        } detail: {
            Text("Select list")
        }
#endif
    }
}

struct ListRootView_Previews: PreviewProvider {
    static var previews: some View {
        ListsRootView()
    }
}
