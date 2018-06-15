import Quick
import Nimble
import BigDiffer
import ListDiff
import KIF

private struct SectionedValue: RandomAccessCollection, BigDiffableSection {
    // NOTE: best practice: using Generics makes slower unless specialized
    var section: String
    var values: [String]

    // NOTE: fast index is provided by conforming RandomAccessCollection
    var startIndex: Int {return values.startIndex}
    var endIndex: Int {return values.endIndex}
    func index(after i: Int) -> Int {return i + 1}
    subscript(position: Int) -> String {return values[position]}

    var diffIdentifier: AnyHashable {return section.diffIdentifier}
}
extension String: BigDiffer.Diffable {
    public var diffIdentifier: AnyHashable {return hashValue}
}

final class TestableTableViewController: UITableViewController {
    fileprivate var datasource: [SectionedValue] = [] {
        didSet {
            tableView.reloadUsingBigDiff(old: oldValue, new: datasource)
        }
    }

    // recorder
    fileprivate var cellForRowHistory: [IndexPath] = []

    override func numberOfSections(in tableView: UITableView) -> Int {return datasource.count}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return datasource[section].count}
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRowHistory.append(indexPath)

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = datasource[indexPath.section][indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {return datasource[section].section}

    func presentOnNewWindow(frame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 320)) {
        let window = UIWindow(frame: frame)
        window.rootViewController = self
        window.makeKeyAndVisible()
    }
}

extension KIFUITestActor {
    func waitForCell(text: String, in tableView: UITableView) -> (cell: UITableViewCell, indexPath: IndexPath)? {
        guard let cell = waitForView(withAccessibilityLabel: text) as? UITableViewCell else { return nil }
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return (cell, indexPath)
    }
}

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            KIFEnableAccessibility()
        }

        beforeEach {
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        }

        context("multi-section") {
            it("cold load") {
                let ttvc = TestableTableViewController(style: .plain)
                ttvc.presentOnNewWindow()
                ttvc.datasource = [
                    SectionedValue(section: "S1", values: ["A", "B"]),
                    SectionedValue(section: "S2", values: ["P", "Q"])]

                let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!
                expect(tester.waitForCell(text: "A", in: ttvc.tableView)?.indexPath) == IndexPath(row: 0, section: 0)
                expect(tester.waitForCell(text: "B", in: ttvc.tableView)?.indexPath) == IndexPath(row: 1, section: 0)
                expect(tester.waitForCell(text: "P", in: ttvc.tableView)?.indexPath) == IndexPath(row: 0, section: 1)
                expect(tester.waitForCell(text: "Q", in: ttvc.tableView)?.indexPath) == IndexPath(row: 1, section: 1)
            }

            it("load inserted row") {
                let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!

                let ttvc = TestableTableViewController(style: .plain)
                ttvc.presentOnNewWindow()
                ttvc.datasource = [
                    SectionedValue(section: "S1", values: ["A", "B"]),
                    SectionedValue(section: "S2", values: ["P", "Q"])]
                tester.waitForAnimationsToFinish()

                expect(ttvc.cellForRowHistory.count) == 4
                ttvc.cellForRowHistory.removeAll()

                ttvc.datasource = [
                    SectionedValue(section: "S1", values: ["A", "B", "C"]),
                    SectionedValue(section: "S2", values: ["P", "Q"])]
                tester.waitForAnimationsToFinish()

                expect(ttvc.cellForRowHistory) == [IndexPath(row: 2, section: 0)]
                expect(tester.waitForCell(text: "C", in: ttvc.tableView)?.indexPath) == IndexPath(row: 2, section: 0)
            }

            it("reload invisible section") {
                let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!

                let ttvc = TestableTableViewController(style: .plain)
                ttvc.presentOnNewWindow()
                ttvc.datasource = [
                    SectionedValue(section: "S1", values: (UnicodeScalar("A").value...UnicodeScalar("Z").value).map {String(UnicodeScalar($0)!)}),
                    SectionedValue(section: "S2", values: ["P", "Q"])]
                tester.waitForAnimationsToFinish()

                expect(ttvc.tableView.indexPathsForVisibleRows).notTo(contain([
                    IndexPath(row: 0, section: 1),
                    IndexPath(row: 1, section: 1)]))
                ttvc.cellForRowHistory.removeAll()

                ttvc.datasource = [
                    SectionedValue(section: "S1", values: ["A", "B"]),
                    SectionedValue(section: "S2", values: ["P", "Q"])]
                tester.waitForAnimationsToFinish()

                expect(Set(ttvc.cellForRowHistory)) == Set([
                    IndexPath(row: 0, section: 1), // unchanged but reloaded because of invisibility before
                    IndexPath(row: 1, section: 1)]) // unchanged but reloaded because of invisibility before
            }

            it("fallback to reload section") {
                let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!

                let ttvc = TestableTableViewController(style: .plain)
                ttvc.presentOnNewWindow()
                ttvc.datasource = [
                    SectionedValue(section: "S1", values: (UnicodeScalar("A").value...UnicodeScalar("Z").value).map {String(UnicodeScalar($0)!)}),
                    SectionedValue(section: "S2", values: (1...500).map {String($0)})]
                tester.waitForAnimationsToFinish()
                ttvc.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                tester.waitForAnimationsToFinish()

                expect(ttvc.tableView.indexPathsForVisibleRows).to(contain([
                    IndexPath(row: 0, section: 1),
                    IndexPath(row: 1, section: 1)]))
                ttvc.cellForRowHistory.removeAll()

                ttvc.datasource = [
                    SectionedValue(section: "S2", values: (1...5).map {String($0)}),  // test condition here: many deletions to fallback to reload the section
                    SectionedValue(section: "S1", values: (UnicodeScalar("A").value...UnicodeScalar("Z").value).map {String(UnicodeScalar($0)!)})]
                tester.waitForAnimationsToFinish()

                // NOTE: cannot actually test completely as the scroll position cannot be assumed
            }
        }
    }
}

final class PerformanceTest: XCTestCase {
    override func setUp() {
        super.setUp()
        KIFEnableAccessibility()
    }

    func testLargeNumberToLargeNumber() {
        let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()

        let ttvc = TestableTableViewController(style: .plain)
        ttvc.presentOnNewWindow()

        let all = Array((0..<5000).map {String($0)})
        var copied = all
        var shuffled: [String] = []
        while !copied.isEmpty {
            shuffled.append(copied.remove(at: Int(arc4random_uniform(UInt32(copied.count)))))
        }

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            ttvc.datasource = [SectionedValue(section: "S1", values: all)]
            tester.waitForAnimationsToFinish()

            startMeasuring()
            ttvc.datasource = [SectionedValue(section: "S1", values: shuffled)]
            tester.waitForAnimationsToFinish() // should take major time to animate, but we need total time
        }
    }

    // NOTE: test for case that: many deletions cause significant performance issue without fallbacks
    func testLargeNumberToZero() {
        let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()

        let ttvc = TestableTableViewController(style: .plain)
        ttvc.presentOnNewWindow()

        let before = Array((0..<5000).map {String($0)})
        let after: [String] = []

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            ttvc.datasource = [SectionedValue(section: "S1", values: before)]
            tester.waitForAnimationsToFinish()

            startMeasuring()
            ttvc.datasource = [SectionedValue(section: "S1", values: after)]
            tester.waitForAnimationsToFinish() // should take major time to animate, but we need total time
        }
    }

    // NOTE: test for case that of non-zero case: many deletions cause significant performance issue without fallbacks
    func testLargeNumberToOne() {
        let tester = KIFUITestActor(file: #file, line: #line, delegate: self)!
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()

        let ttvc = TestableTableViewController(style: .plain)
        ttvc.presentOnNewWindow()


        let before = Array((0..<5000).map {String($0)})
        let after: [String] = ["0"]

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            ttvc.datasource = [SectionedValue(section: "S1", values: before)]
            tester.waitForAnimationsToFinish()

            startMeasuring()
            ttvc.datasource = [SectionedValue(section: "S1", values: after)]
            tester.waitForAnimationsToFinish() // should take major time to animate, but we need total time
        }
    }
}
