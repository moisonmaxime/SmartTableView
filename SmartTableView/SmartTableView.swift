//
//  SmartTableView.swift
//  Lynx
//
//  Created by Maxime Moison on 9/1/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

class SmartTableView: UITableView {

    /// Array of the rows currently loaded in the table view
    private(set) var rows: [SmartCell] = []

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // SmartTableView is its own delegate and dataSource
    private func setup() {
        separatorStyle = .none
        dataSource = self
        delegate = self
    }

    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Insertion/Deletion
    func resetTo(rows rowsToSet: [SmartCell]) {
        rows = rowsToSet
        reloadData()
    }

    func insert(row: SmartCell, at index: Int,
                with animation: UITableViewRowAnimation = .automatic) {
        insert(rows: [row], at: index)
    }

    func insert(rows rowsToAdd: [SmartCell], at index: Int,
                with animation: UITableViewRowAnimation = .automatic) {
        rows.insert(contentsOf: rowsToAdd, at: index)
        let indexPaths = (index..<(index+rowsToAdd.count)).map({ return IndexPath(row: $0, section: 0) })
        insertRows(at: indexPaths, with: animation)
    }

    func reload(row: Int,
                with animation: UITableViewRowAnimation = .automatic) {
        reload(rows: [row], with: animation)
    }

    func reload(rows: [Int],
                with animation: UITableViewRowAnimation = .automatic) {
        reloadRows(at: rows.map({ IndexPath(row: $0, section: 0)}), with: animation)
    }

    func delete(row index: Int,
                with animation: UITableViewRowAnimation = .automatic) {
        rows.remove(at: index)
        deleteRows(at: [IndexPath(row: index, section: 0)], with: animation)
    }

    func delete(rows indexes: [Int],
                with animation: UITableViewRowAnimation = .automatic) {
        for index in indexes.sorted().reversed() {
            rows.remove(at: index)
        }
        deleteRows(at: indexes.map({ return IndexPath(row: $0, section: 0) }), with: animation)
    }

    func delete(count: Int, at startIndex: Int,
                with animation: UITableViewRowAnimation = .automatic) {
        let indexes = (startIndex..<(startIndex+count))
        for _ in indexes {
            rows.remove(at: startIndex)
        }
        let indexPaths = indexes.map({ return IndexPath(row: $0, section: 0) })
        deleteRows(at: indexPaths, with: animation)
    }
}




extension SmartTableView: UITableViewDataSource, UITableViewDelegate {

    // Data (size)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    // Cell Loading
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rows[indexPath.row].selectionStyle = .none
        return rows[indexPath.row]
    }

    // Actions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var expandable = rows[indexPath.row] as? CellExpandable {
            if expandable.isCollapsed {
                insert(rows: expandable.collapsibleCells, at: indexPath.row+1)
            } else {
                delete(count: expandable.collapsibleCells.count, at: indexPath.row+1)
            }
            let newCollapsedStated = !expandable.isCollapsed
            expandable.isCollapsed = newCollapsedStated
        }
        if let actionable = rows[indexPath.row] as? CellActionable {
            actionable.onTap?()
        }
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let swipeableCell = rows[indexPath.row] as? CellLeadingSwipeActionable else {
            return UISwipeActionsConfiguration(actions: [])
        }
        let cellSwipeActions = swipeableCell.leadingSwipeActions
        let actions = cellSwipeActions.map { return cellSwipeActionToContextualAction($0, for: rows[indexPath.row], at: indexPath) }
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let swipeableCell = rows[indexPath.row] as? CellTrailingSwipeActionable else {
            return UISwipeActionsConfiguration(actions: [])
        }
        let cellSwipeActions = swipeableCell.trailingSwipeActions
        let actions = cellSwipeActions.map { return cellSwipeActionToContextualAction($0, for: rows[indexPath.row], at: indexPath) }
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func cellSwipeActionToContextualAction(_ swipeAction: CellSwipeAction,
                                                   for cell: SmartCell,
                                                   at indexPath: IndexPath) -> UIContextualAction {
        let contextualAction = UIContextualAction(style: swipeAction.style, title: swipeAction.title, handler: {_, _, successHandler in
            swipeAction.handler(self, indexPath.row)
            successHandler(true)
        })
        if let color = swipeAction.color { contextualAction.backgroundColor = color }
        contextualAction.image = swipeAction.image
        return contextualAction
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sizeable = rows[indexPath.row] as? CellSizeable else { return UITableViewAutomaticDimension }
        return sizeable.height
    }
}
