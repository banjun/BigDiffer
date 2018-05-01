import Eureka

final class MenuViewController: FormViewController {
    init() {
        super.init(style: .grouped)

        title = "BigDiffer Sandbox"

        form +++ Section()
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(SingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            <<< LabelRow {
                $0.title = "Multi-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(MultiSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(true, animated: animated)
    }
}
