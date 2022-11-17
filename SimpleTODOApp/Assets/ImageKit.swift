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
}

extension String {
    var systemImage: Image {
        Image(systemName: self)
    }
}
