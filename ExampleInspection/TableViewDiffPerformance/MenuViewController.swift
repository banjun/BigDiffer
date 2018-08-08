import UIKit
import Eureka

final class MenuViewController: FormViewController {
    init() {
        super.init(nibName: nil, bundle: nil)


        form +++ Eureka.Section()
            <<< LabelRow {
                $0.title = "TableView"
                $0.cell.accessoryType = .disclosureIndicator
                $0.onCellSelection {[unowned self] _, _ in self.show(MainTableViewController(), sender: nil)}
            }
            +++ Eureka.Section()
            <<< LabelRow {
                $0.title = "Deletion Performance"
                $0.cell.accessoryType = .disclosureIndicator
                $0.onCellSelection {[unowned self] _, _ in self.show(DeletionPerformanceViewController(), sender: nil)}
        }
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}
}

