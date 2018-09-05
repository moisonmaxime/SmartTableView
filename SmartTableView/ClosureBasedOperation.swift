//
//  ClosureBasedOperation.swift
//  SmartTableView
//
//  Created by Maxime Moison on 9/4/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

public class ClosureBasedOperation: Operation {
    private var block: () -> Void

    init(block: @escaping () -> Void) {
        self.block = block
        super.init()
    }

    override public func main() {
        block()
    }
}
