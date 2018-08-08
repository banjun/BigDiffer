import UIKit

final class DeletionPerformanceViewController: UITableViewController {
    private var numberOfRows: Int = 0 {
        didSet {
            reloadRows(oldValue: oldValue)
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        measure()
    }

    private func measure() {
        (0...100).map {$0 * 100}.forEach {
            numberOfRows = $0
            numberOfRows = 0
        }
    }

    private func reloadRows(oldValue: Int) {
        UIView.performWithoutAnimation {
            let start = Date()
            let type: String
            if numberOfRows < oldValue {
                type = "deletion"
                tableView.deleteRows(at: (numberOfRows..<oldValue).map {IndexPath(row: $0, section: 0)}, with: .none)
            } else {
                type = "insertion"
                tableView.insertRows(at: (oldValue..<numberOfRows).map {IndexPath(row: $0, section: 0)}, with: .none)
            }
            let end = Date()
            let duration = end.timeIntervalSince(start)
            print(String(format: "%@\t%d\t%d\t%.2f", type, oldValue, numberOfRows, duration))
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Item \(indexPath.row)"
        return cell
    }
}
