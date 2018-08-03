import UIKit
import ReactiveSwift
import ReactiveCocoa
import NorthLayout
import Ikemen

struct Section {
    var header: String?
    var items: [Item]
}

struct Item {
    var name: String
}

final class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private lazy var tableView = UITableView(frame: .zero, style: .plain) ※ {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 64
    }
    private lazy var datasource = MutableProperty<[Section]>([]) ※ {
        $0.signal.take(duringLifetimeOf: self).observeValues {_ in
            self.tableView.reloadData()
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
        datasource.value = [
            Section(header: "Section 1",
                    items: (1...5000).map {
                        Item(name: "Item \($0)")
            })]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.value[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource.value[section].header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = datasource.value[indexPath.section].items[indexPath.row].name
        cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "Remove") { [unowned self] _, indexPath in
            self.datasource.value[indexPath.section].items.remove(at: indexPath.row)
        }]
    }
}
