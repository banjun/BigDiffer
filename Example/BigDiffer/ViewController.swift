import UIKit
import Differ
import BigDiffer

final class ViewController: UITableViewController, UISearchResultsUpdating {
    private var datasource: [String] = [] {
        didSet {filteredDatasource = searchText.isEmpty ? datasource : datasource.filter {$0.contains(searchText)}}
    }
    private var searchText: String = "" {
        didSet {filteredDatasource = searchText.isEmpty ? datasource : datasource.filter {$0.contains(searchText)}}
    }
    private var filteredDatasource: [String] = [] {
        didSet {diffAndPatch(old: oldValue, new: filteredDatasource)}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 12)]

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortRows))

        toolbarItems = [
            UIBarButtonItem(title: "1 Row", style: .plain, target: self, action: #selector(updateTo1Row)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "5 Rows", style: .plain, target: self, action: #selector(updateTo5Row)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "5000 Rows", style: .plain, target: self, action: #selector(updateTo5000Row))]

        if #available(iOS 11, *) {
            let sc = UISearchController(searchResultsController: nil)
            sc.searchResultsUpdater = self
            navigationItem.searchController = sc
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)
    }

    func diffAndPatch(old: [String], new: [String]) {
        let started = Date()

        let diff = old.extendedDiff(new)
        let diffed = Date()

        // tableView.apply(diff)
        tableView.applyWithOptimizations(diff)
        let applied = Date()

        let measures = String(format: "diff: %.1fs, apply: %.1fs, total: %.1fs",
                              diffed.timeIntervalSince(started),
                              applied.timeIntervalSince(diffed),
                              applied.timeIntervalSince(started))
        title = "\(filteredDatasource.count) Rows (\(measures))"
    }

    @objc private func updateTo1Row() {
        datasource = Array(Data.gemojiFoodsByPeople.prefix(1))
    }

    @objc private func updateTo5Row() {
        datasource = Array(Data.gemojiFoodsByPeople.dropFirst(5).prefix(5))
    }

    @objc private func updateTo5000Row() {
        datasource = Array(Data.gemojiFoodsByPeople.prefix(5000))
    }

    @objc private func sortRows() {
        filteredDatasource.sort {
            $0.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789").inverted).filter {!$0.isEmpty}.joined(separator: " ")
                < $1.components(separatedBy: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789").inverted).filter {!$0.isEmpty}.joined(separator: " ")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDatasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = filteredDatasource[indexPath.row]
        return cell
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
    }
}

