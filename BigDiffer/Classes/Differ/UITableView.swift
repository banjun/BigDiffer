import UIKit
import Differ

public enum Threshold {
    public static let maxRowsToCalculateDiffs = 3000 // Differ cost: O((N+M)*D)
    public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
}

extension UITableView {
    public func applyWithOptimizations(
        _ diff: ExtendedDiff,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        maxDeletionsPreservingAnimations: Int = Threshold.maxDeletionsPreservingAnimations
        ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)

        // number of deletions affect tableview performance exponentially including non-visible deletions
        let fallback = update.deletions.count > maxDeletionsPreservingAnimations

        if fallback {
            // animations no longer meaningful
            UIView.performWithoutAnimation {
                beginUpdates()
                defer {endUpdates()}

                reloadSections([0], with: .none)
            }
        } else {
            beginUpdates()
            defer {endUpdates()}

            deleteRows(at: update.deletions, with: deletionAnimation)
            insertRows(at: update.insertions, with: insertionAnimation)
            update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        }
    }

    // wrapper for applyWithOptimizations, c.f. original animateRowChanges
    public func animateRowChangesWithOptimizations<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        maxRowsToCalculateDiffs: Int = Threshold.maxRowsToCalculateDiffs,
        maxDeletionsPreservingAnimations: Int = Threshold.maxDeletionsPreservingAnimations
        ) where T.Iterator.Element: Equatable {
        guard oldData.count + newData.count <= maxRowsToCalculateDiffs else {
            reloadSections([0], with: .none)
            return
        }

        applyWithOptimizations(
            oldData.extendedDiff(newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            indexPathTransform: indexPathTransform,
            maxDeletionsPreservingAnimations: maxDeletionsPreservingAnimations
        )
    }

    public func applyWithOptimizations(
        _ diff: NestedExtendedDiff,
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath,
        sectionTransform: (Int) -> Int,
        maxDeletionsPreservingAnimations: Int = Threshold.maxDeletionsPreservingAnimations
        ) {
        let update = NestedBatchUpdate(diff: diff, indexPathTransform: indexPathTransform, sectionTransform: sectionTransform)

        // number of deletions affect tableview performance exponentially including non-visible deletions
        let fallback = update.itemDeletions.count > maxDeletionsPreservingAnimations

        if fallback {
            reloadData() // TODO: more fine-grained reloadSections
        } else {
            beginUpdates()
            deleteRows(at: update.itemDeletions, with: rowDeletionAnimation)
            insertRows(at: update.itemInsertions, with: rowInsertionAnimation)
            update.itemMoves.forEach { moveRow(at: $0.from, to: $0.to) }
            deleteSections(update.sectionDeletions, with: sectionDeletionAnimation)
            insertSections(update.sectionInsertions, with: sectionInsertionAnimation)
            update.sectionMoves.forEach { moveSection($0.from, toSection: $0.to) }
            endUpdates()
        }
    }

    // wrapper for applyWithOptimizations, c.f. original animateRowChanges
    public func animateRowAndSectionChangesWithOptimizations<T: Collection>(
        oldData: T,
        newData: T,
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 },
        maxRowsToCalculateDiffs: Int = Threshold.maxRowsToCalculateDiffs,
        maxDeletionsPreservingAnimations: Int = Threshold.maxDeletionsPreservingAnimations
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable,
        T.Iterator.Element.Iterator.Element: Equatable {
            guard oldData.count + newData.count <= maxRowsToCalculateDiffs else {
                reloadData() // TODO: more fine-grained reloadSections
                return
            }

            applyWithOptimizations(
                oldData.nestedExtendedDiff(to: newData),
                rowDeletionAnimation: rowDeletionAnimation,
                rowInsertionAnimation: rowInsertionAnimation,
                sectionDeletionAnimation: sectionDeletionAnimation,
                sectionInsertionAnimation: sectionInsertionAnimation,
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                maxDeletionsPreservingAnimations: maxDeletionsPreservingAnimations
            )
    }
}

extension BatchUpdate: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        deletions: \(deletions.map {"\($0.section, $0.row)"}),
        insertions: \(insertions.map {"\($0.section, $0.row)"}),
        moves: \(moves.map {"\($0.from.section, $0.from.row) -> \($0.to.section, $0.to.row)"})
        """
    }
}


// NOTE: struct NestedBatchUpdate is just copied from Differ/NestedBatchUpdate.swift because it is currently internal
struct NestedBatchUpdate {
    let itemDeletions: [IndexPath]
    let itemInsertions: [IndexPath]
    let itemMoves: [(from: IndexPath, to: IndexPath)]
    let sectionDeletions: IndexSet
    let sectionInsertions: IndexSet
    let sectionMoves: [(from: Int, to: Int)]

    init(
        diff: NestedExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        ) {
        var itemDeletions: [IndexPath] = []
        var itemInsertions: [IndexPath] = []
        var itemMoves: [(IndexPath, IndexPath)] = []
        var sectionDeletions: IndexSet = []
        var sectionInsertions: IndexSet = []
        var sectionMoves: [(from: Int, to: Int)] = []

        diff.forEach { element in
            switch element {
            case let .deleteElement(at, section):
                itemDeletions.append(indexPathTransform([section, at]))
            case let .insertElement(at, section):
                itemInsertions.append(indexPathTransform([section, at]))
            case let .moveElement(from, to):
                itemMoves.append((indexPathTransform([from.section, from.item]), indexPathTransform([to.section, to.item])))
            case let .deleteSection(at):
                sectionDeletions.insert(sectionTransform(at))
            case let .insertSection(at):
                sectionInsertions.insert(sectionTransform(at))
            case let .moveSection(move):
                sectionMoves.append((sectionTransform(move.from), sectionTransform(move.to)))
            }
        }

        self.itemInsertions = itemInsertions
        self.itemDeletions = itemDeletions
        self.itemMoves = itemMoves
        self.sectionMoves = sectionMoves
        self.sectionInsertions = sectionInsertions
        self.sectionDeletions = sectionDeletions
    }
}

