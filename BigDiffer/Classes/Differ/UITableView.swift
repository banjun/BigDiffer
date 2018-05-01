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
