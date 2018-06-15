import UIKit

extension UITableView {
    public func bigDiff<T: BigDiffableSection>(old: [T], new: [T], maxDeletionsPreservingAnimations: Int = Threshold.BigDiffer.maxDeletionsPreservingAnimations) -> Changeset? {
        return Changeset(old: old, new: new, visibleIndexPaths: indexPathsForVisibleRows ?? [], maxDeletionsPreservingAnimations: maxDeletionsPreservingAnimations)
    }

    public func apply(
        bigDiff: Changeset,
        rowDeletionAnimation: UITableViewRowAnimation = .fade,
        rowInsertionAnimation: UITableViewRowAnimation = .fade,
        sectionDeletionAnimation: UITableViewRowAnimation = .fade,
        sectionInsertionAnimation: UITableViewRowAnimation = .fade,
        sectionReloadingAnimation: UITableViewRowAnimation = .fade) {
        CATransaction.begin()
        beginUpdates()
        defer {
            endUpdates()
            CATransaction.setCompletionBlock {
                // deleting all sections & inserting all sections
                // with content offset > page size may cause blank page after an animation.
                // in the case, contentOffset.y has negative large number.
                // we add workaround for that by resetting the offset
                let minContentOffset: CGFloat

                if #available(iOS 11, *) {
                    minContentOffset = -self.adjustedContentInset.top
                } else {
                    minContentOffset = -self.contentInset.top
                }

                if self.contentOffset.y < minContentOffset {
                    self.contentOffset.y = minContentOffset
                }
            }
            CATransaction.commit()
        }

        deleteSections(.init(bigDiff.deletedSectionIndices), with: sectionDeletionAnimation)
        deleteRows(at: bigDiff.deletionsInSections, with: rowDeletionAnimation)
        bigDiff.sectionMoves.forEach {
            // mixing moveSection and delete/insert rows may cause crash
            // see comments at https://github.com/RxSwiftCommunity/RxDataSources/blob/master/Sources/Differentiator/Diff.swift#L232
            deleteSections([$0.from], with: sectionDeletionAnimation)
            insertSections([$0.to], with: sectionInsertionAnimation)
            // moveSection($0.from, toSection: $0.to)
        }
        insertSections(.init(bigDiff.insertedSectionIndices), with: sectionInsertionAnimation)
        insertRows(at: bigDiff.insertionsInSections, with: rowInsertionAnimation)
        reloadSections(.init(bigDiff.reloadableSectionIndices + bigDiff.fallbackedToReloadSectionIndices), with: sectionReloadingAnimation)
    }

    public func reloadUsingBigDiff<T: BigDiffableSection>(
        old: [T],
        new: [T],
        rowDeletionAnimation: UITableViewRowAnimation = .fade,
        rowInsertionAnimation: UITableViewRowAnimation = .fade,
        sectionDeletionAnimation: UITableViewRowAnimation = .fade,
        sectionInsertionAnimation: UITableViewRowAnimation = .fade,
        sectionReloadingAnimation: UITableViewRowAnimation = .fade,
        maxDeletionsPreservingAnimations: Int = Threshold.BigDiffer.maxDeletionsPreservingAnimations) {
        guard let diff = bigDiff(old: old, new: new, maxDeletionsPreservingAnimations: maxDeletionsPreservingAnimations) else {
            reloadData()
            return
        }
        apply(bigDiff: diff,
              rowDeletionAnimation: rowDeletionAnimation,
              rowInsertionAnimation: rowInsertionAnimation,
              sectionDeletionAnimation: sectionDeletionAnimation,
              sectionInsertionAnimation: sectionInsertionAnimation,
              sectionReloadingAnimation: sectionReloadingAnimation)
    }
}
