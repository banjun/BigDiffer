import UIKit
import Differ

final class ViewController: UITableViewController {
    private var datasource: [String] = [] {
        didSet {diffAndPatch(old: oldValue, new: datasource)}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 12)]

        toolbarItems = [
            UIBarButtonItem(title: "1 Row", style: .plain, target: self, action: #selector(updateTo1Row)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "5000 Rows", style: .plain, target: self, action: #selector(updateTo5000Row))]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)
    }

    func diffAndPatch(old: [String], new: [String]) {
        let started = Date()

        let diff = old.extendedDiff(new)
        let diffed = Date()

        tableView.apply(diff)
        let applied = Date()

        let measures = String(format: "diff: %.1fs, apply: %.1fs, total: %.1fs",
                              diffed.timeIntervalSince(started),
                              applied.timeIntervalSince(diffed),
                              applied.timeIntervalSince(started))
        title = "\(datasource.count) Rows (\(measures))"
    }

    @objc private func updateTo1Row() {
        datasource = Array(Data.gemojiFoodsByPeople.prefix(1))
    }

    @objc private func updateTo5000Row() {
        datasource = Array(Data.gemojiFoodsByPeople.prefix(5000))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = datasource[indexPath.row]
        return cell
    }
}

