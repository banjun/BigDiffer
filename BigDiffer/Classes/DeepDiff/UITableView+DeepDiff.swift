import UIKit
import DeepDiff

extension Threshold {
    public enum DeepDiff {
        public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
    }
}

extension UITableView {
    public func reloadWithOptimizations<T: Hashable>(
        changes: [Change<T>],
        section: Int = 0,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        replacementAnimation: UITableViewRowAnimation = .automatic,
        completion: @escaping (Bool) -> Void,
        maxDeletionsPreservingAnimations: Int = Threshold.DeepDiff.maxDeletionsPreservingAnimations) {
        let changesWithIndexPath = IndexPathConverter().convert(changes: changes, section: section)

        // number of deletions affect tableview performance exponentially including non-visible deletions
        // NOTE: moves may also cost, unlikely to insertions
        let fallback = changesWithIndexPath.deletes.count > maxDeletionsPreservingAnimations

        if fallback {
            // animations no longer meaningful
            UIView.performWithoutAnimation {
                reloadSections([section], with: .none)
            }
        } else {
            reload(changes: changes, section: section, insertionAnimation: insertionAnimation, deletionAnimation: deletionAnimation, replacementAnimation: replacementAnimation, completion: completion)
        }
    }
}
