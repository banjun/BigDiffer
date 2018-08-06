import UIKit
import DifferenceKit

extension Threshold {
    public enum DifferenceKit {
        public static let maxRowsToCalculateDiffs = 10000 // Heckel cost: O(N+M)
        public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
    }
}

extension UITableView {
    public func reloadWithOptimizations<C>(
        source: C,
        target: C,
        with animation: @autoclosure () -> UITableViewRowAnimation,
        maxRowsToCalculateDiffs: Int = Threshold.DifferenceKit.maxRowsToCalculateDiffs,
        maxDeletionsPreservingAnimations: Int = Threshold.DifferenceKit.maxDeletionsPreservingAnimations,
        setData: (C) -> Void) where C: RangeReplaceableCollection, C.Element: Differentiable {
        guard source.count + target.count <= maxRowsToCalculateDiffs else {
            setData(target)
            reloadData()
            return
        }
        let stagedChangeset = StagedChangeset(source: source, target: target)
        reloadWithOptimizations(using: stagedChangeset, with: animation, maxDeletionsPreservingAnimations: maxDeletionsPreservingAnimations, setData: setData)
    }

    public func reloadWithOptimizations<C>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> UITableViewRowAnimation,
        maxDeletionsPreservingAnimations: Int = Threshold.DifferenceKit.maxDeletionsPreservingAnimations,
        setData: (C) -> Void) where C: RangeReplaceableCollection, C.Element: Differentiable {
        reload(using: stagedChangeset, with: animation, interrupt: {$0.elementDeleted.count > maxDeletionsPreservingAnimations}, setData: setData)
    }
}
