import UIKit
import NorthLayout
import Ikemen

struct Section {
    var header: String?
    var items: [Item]
}

struct Item: Equatable {
    var name: String
}

final class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private lazy var tableView: UITableView = .init(frame: .zero, style: .plain) ※ {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 64
    }
    private lazy var searchBar: UISearchBar = .init(frame: .zero) ※ {
        $0.delegate = self
        $0.searchBarStyle = .minimal
    }

    private var datasource: [Section] = [] {
        didSet {updateFilteredSections()}
    }
    private var searchText: String = "" {
        didSet {updateFilteredSections()}
    }
    private var filteredSections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private func updateFilteredSections() {
        guard !searchText.isEmpty else {
            filteredSections = datasource
            return
        }
        filteredSections = datasource.map { s in
            return Section(header: s.header, items: s.items.filter {
                return $0.name.contains(searchText)
            })
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Main Table"

        let autolayout = northLayoutFormat([:], ["table": tableView])
        autolayout("H:|[table]|")
        autolayout("V:|[table]|")
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = [Section(
            header: "Section 1",
            items: (1...5000).map {
                Item(name: "Item \($0)")
        })]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame.size = .init(width: view.bounds.width, height: 64)
        tableView.tableHeaderView = searchBar
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = filteredSections[section]
        return s.header.map {$0 + " (\(s.items.count) items)"}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = filteredSections[indexPath.section].items[indexPath.row].name
        cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "Remove") { [unowned self] _, indexPath in
            let item = self.filteredSections[indexPath.section].items[indexPath.row]
            self.datasource = self.datasource.map { s in
                Section(header: s.header, items: s.items.filter {$0 != item})
            }
        }]
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
