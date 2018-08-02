import UIKit
import EditDistance

extension Threshold {
    public enum EditDistance {
        public static let maxRowsToCalculateDiffs = 10000 // Wu cost: O(NP)
        public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
    }
}

extension EditScriptConverterProxy where Converter: UITableView {
    public func reloadWithOptimization<T>(with container: EditDistanceContainer<T>,
                                          maxDeletionsPreservingAnimations: Int = Threshold.EditDistance.maxDeletionsPreservingAnimations,
                                          fallbackBlock: () -> Void) {
        // number of deletions affect tableview performance exponentially including non-visible deletions
        let deletions = container.editScripts.filter {
            switch $0 {
            case .delete: return true
            case .add, .common: return false
            }
            }.count
        let fallback = deletions > maxDeletionsPreservingAnimations

        if fallback {
            fallbackBlock()
        } else {
            reload(with: container)
        }
    }
}
