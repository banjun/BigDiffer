import UIKit

struct SectionedValue: Equatable, RandomAccessCollection {
    // NOTE: best practice: using Generics makes slower unless specialized
    var section: String
    var values: [String]

    // NOTE: fast index is provided by conforming RandomAccessCollection
    var startIndex: Int {return values.startIndex}
    var endIndex: Int {return values.endIndex}
    func index(after i: Int) -> Int {return i + 1}
    subscript(position: Int) -> String {return values[position]}

    static func == (lhs: SectionedValue, rhs: SectionedValue) -> Bool {
        return lhs.section == rhs.section
    }
}

final class DifferMultiSectionTableViewController: UITableViewController {
    var datasource: [SectionedValue] = [] {
        didSet {diffAndPatch(old: oldValue, new: datasource)}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        toolbarItems = [
            UIBarButtonItem(title: "1,1 Row", style: .plain, target: self, action: #selector(makeRow1Row1)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "5,5 Rows", style: .plain, target: self, action: #selector(makeRow5Row5)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "More Rows", style: .plain, target: self, action: #selector(populateRows))]
        // TODO: more actions
        // - insert,delete,moveSection
        // - move items between sections

        populateRows()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 12)]
    }

    func diffAndPatch(old: [SectionedValue], new: [SectionedValue]) {
        let started = Date()

        let diff = old.nestedExtendedDiff(to: new)
        let diffed = Date()

        // tableView.apply(diff, indexPathTransform: {$0}, sectionTransform: {$0})
        tableView.applyWithOptimizations(diff, indexPathTransform: {$0}, sectionTransform: {$0})
        let applied = Date()

        let measures = String(format: "diff: %.1fs, apply: %.1fs, total: %.1fs",
                              diffed.timeIntervalSince(started),
                              applied.timeIntervalSince(diffed),
                              applied.timeIntervalSince(started))
        title = "\(datasource.reduce(into: 0) {$0 += $1.count}) Rows (\(measures))"
    }

    @objc private func makeRow1Row1() {
        datasource = [
            SectionedValue(section: "People", values: Array(Data.gemojiPeople.prefix(1))),
            SectionedValue(section: "FoodsByPeople", values: Array(Data.gemojiFoodsByPeople.prefix(1)))]
    }

    @objc private func makeRow5Row5() {
        datasource = [
            SectionedValue(section: "People", values: Array(Data.gemojiPeople.prefix(5))),
            SectionedValue(section: "FoodsByPeople", values: Array(Data.gemojiFoodsByPeople.prefix(5)))]
    }

    @objc private func populateRows() {
        datasource = [
            SectionedValue(section: "People", values: Data.gemojiPeople),
            SectionedValue(section: "FoodsByPeople", values: Array(Data.gemojiFoodsByPeople.prefix(5000)))]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = datasource[section]
        return "\(s.section) (\(s.count))"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = datasource[indexPath.section][indexPath.row]
        return cell
    }
}
