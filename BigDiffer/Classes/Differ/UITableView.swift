import UIKit
import Differ

extension UITableView {
    public func applyWithOptimizations(
        _ diff: ExtendedDiff,
        numberOfRows: Int,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
        ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)

        beginUpdates()
        defer {endUpdates()}

        // number of deletions affect tableview performance exponentially including non-visible deletions
        if update.deletions.count < 300 {
            deleteRows(at: update.deletions, with: deletionAnimation)
            insertRows(at: update.insertions, with: insertionAnimation)
            update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        } else {
            let recoveredInsertions: [IndexPath] = (0..<numberOfRows)
                .map {IndexPath(row: $0, section: 0)}
                .filter {!update.deletions.contains($0)}

            deleteSections([0], with: .none)
            insertSections([0], with: .none)
            insertRows(at: recoveredInsertions, with: insertionAnimation)
            update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        }
    }
}
