//
//  SmartCell.swift
//  SmartTableView
//
//  Created by Maxime Moison on 9/4/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

/// Allows a cell to be loaded with a cellModel (usually a struct).
/// This is supposed to be used when the cell is initially created.
public protocol CellLoadable {
    associatedtype Model
    var model: Model? { get set }
    func loadCell(_ model: Model)
}

/// Allows a cell that has a heavier loading process to be loaded when it appears.
/// Call onShow when it appears, call onExpire when memory needs to be freed
public protocol CellComplexLoadable {
    var loadingDate: Date? { get set }
    var onShow: (() -> Void)? { get }
    var onExpire: (() -> Void)? { get }
}

/// Allows a cell to actionable when tapped.
/// This is supposed to be used when the cell is selected (selectAtIndex...).
public protocol CellActionable {
    var onTap: (() -> Void)? { get }
    var onHighlight: ((Bool) -> Void)? { get }
}

/// Allows a cell to specify its height
public protocol CellSizeable {
    var height: CGFloat { get }
}

/// Allows a cell to be expandable with multiple children cells.
public protocol CellExpandable {
    var collapsibleCells: [SmartCell] { get }
    var isCollapsed: Bool { get set }
}

/// Allows a cell to have leading swiping actions.
public protocol CellLeadingSwipeActionable {
    var leadingSwipeActions: [CellSwipeAction] { get }
}

/// Allows a cell to have trailing swiping actions.
public protocol CellTrailingSwipeActionable {
    var trailingSwipeActions: [CellSwipeAction] { get }
}

/// Defines a cell Swipe action for a `CellLeadingSwipeActionable` or `CellTrailingSwipeActionable`
public struct CellSwipeAction {
    typealias CellSwipeActionHandler = (SmartTableView, Int) -> Void
    var title: String?
    var image: UIImage?
    var color: UIColor?
    var handler: CellSwipeActionHandler
    var style: UIContextualAction.Style

    init(title: String?, color: UIColor? = nil, image: UIImage? = nil, style: UIContextualAction.Style = .normal, handler: @escaping CellSwipeActionHandler) {
        self.title = title
        self.color = color
        self.image = image
        self.handler = handler
        self.style = style
    }
}

/// UITableViewCell that calls its onHighlight closure if it has one
public class SmartCell: UITableViewCell {
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard let actionable = self as? CellActionable  else {
            return
        }
        actionable.onHighlight?(highlighted)
    }
}
