//
//  ListRootView.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI

struct ListsRootView: View {
    var body: some View {
        NavigationStack {
            ListsView(
                interactor: ListsInteractor(
                    listsStorageController: ListsStorageControllerImpl()
                )
            )
        }
    }
}

struct ListRootView_Previews: PreviewProvider {
    static var previews: some View {
        ListsRootView()
    }
}
