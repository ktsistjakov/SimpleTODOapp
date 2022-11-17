//
//  ImageKit.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 17.11.2022.
//

import SwiftUI

enum ImageKit {
    enum Lists {
        static let add = "plus.circle"
    }

    enum Todos {
        static let more = "ellipsis.circle"
        static let add = "plus.circle"
        static let done = "checkmark.square"
        static let emptyMark = "square"
    }
}

extension String {
    var systemImage: Image {
        Image(systemName: self)
    }
}
