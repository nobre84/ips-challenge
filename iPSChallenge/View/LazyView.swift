//
//  LazyView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 02/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
