import UIKit
import HeckelDiff

extension Threshold {
    public enum HeckelDiff {
        public static let maxRowsToCalculateDiffs = 5000 // Heckel cost: O(N+M)
        public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
    }
}

extension UITableView {
    public func applyDiffWithOptimizations<T: Collection>(_ old: T, _ new: T, inSection section: Int, withAnimation animation: UITableViewRowAnimation, reloadUpdated: Bool = true, maxRowsToCalculateDiffs: Int = Threshold.HeckelDiff.maxRowsToCalculateDiffs, maxDeletionsPreservingAnimations: Int = Threshold.HeckelDiff.maxDeletionsPreservingAnimations) where T.Iterator.Element: Hashable, T.Index == Int {
        let update = ListUpdate(HeckelDiff.diff(old, new), section)

        // number of deletions affect tableview performance exponentially including non-visible deletions
        // NOTE: moves may also cost, unlikely to insertions
        let fallback = update.deletions.count > maxDeletionsPreservingAnimations

        if fallback {
            // animations no longer meaningful
            UIView.performWithoutAnimation {
                reloadSections([section], with: .none)
            }
        } else {
            beginUpdates()

            deleteRows(at: update.deletions, with: animation)
            insertRows(at: update.insertions, with: animation)
            for move in update.moves {
                moveRow(at: move.from, to: move.to)
            }
            endUpdates()

            // reloadItems is done separately as the update indexes returne by diff() are in respect to the
            // "after" state, but the collectionView.reloadItems() call wants the "before" indexPaths.
            if reloadUpdated && update.updates.count > 0 {
                beginUpdates()
                reloadRows(at: update.updates, with: animation)
                endUpdates()
            }
        }
    }
}
