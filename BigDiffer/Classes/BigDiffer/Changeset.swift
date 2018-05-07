import Foundation
import ListDiff

public typealias Diffable = ListDiff.Diffable

extension Threshold {
    public enum BigDiffer {
        public static let maxDeletionsPreservingAnimations = 300 // UITableView.endUpdates cost: dominated by deletions
    }
}

public protocol BigDiffableSections: Collection where Index == Int, Element: BigDiffableSection {}
public protocol BigDiffableSection: Collection, Equatable where Element: Diffable & Equatable {}
extension Array: BigDiffableSections where Element: BigDiffableSection {}

public struct Changeset {
    public var deletedSectionIndices: [Int] = []
    public var deletionsInSections: [IndexPath] = []
    public var sectionMoves: [(from: Int, to: Int)] = []
    public var insertedSectionIndices: [Int] = []
    public var insertionsInSections: [IndexPath] = []
    public var reloadableSectionIndices: [Int] = []
    public var fallbackedToReloadSectionIndices: [Int] = []
}

extension Changeset {
    public init?<T: BigDiffableSections>(old: T, new: T, visibleIndexPaths: [IndexPath], maxDeletionsPreservingAnimations: Int = Threshold.BigDiffer.maxDeletionsPreservingAnimations) {
        guard !visibleIndexPaths.isEmpty else { return nil }

        // deleted sections on old sections
        deletedSectionIndices = old.enumerated().filter {!new.contains($0.element)}.map {$0.offset}

        // inserted sections on new sections
        insertedSectionIndices = new.enumerated().filter {!old.contains($0.element)}.map {$0.offset}

        // sections are reloadable if completely invisible (omitting move-in animations for performance)
        let remainingSectionIndices = (0..<old.count).filter {!deletedSectionIndices.contains($0)}
        reloadableSectionIndices = remainingSectionIndices.filter {s in !visibleIndexPaths.contains {$0.section == s}}

        // sections that are completely or partially visible
        let needsInspectionSectionIndices = remainingSectionIndices.filter {!reloadableSectionIndices.contains($0)}
        // calculate section-wise diff
        needsInspectionSectionIndices.forEach { oi in
            let o = old[oi]
            let ni = new.index {$0 == o}!
            let n = new[ni]

            if oi != ni {
                sectionMoves.append((oi, ni))
            }

            let diff = List.diffing(oldArray: Array(o), newArray: Array(n))

            if diff.deletes.count > maxDeletionsPreservingAnimations {
                // fallback to just reloading. many deletions take long time
                fallbackedToReloadSectionIndices.append(oi)
            } else {
                deletionsInSections.append(contentsOf: diff.deletes.map {IndexPath(row: $0, section: oi)})
                insertionsInSections.append(contentsOf: diff.inserts.map {IndexPath(row: $0, section: ni)})
            }
        }
    }
}
