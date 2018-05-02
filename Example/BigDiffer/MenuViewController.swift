import Eureka

final class MenuViewController: FormViewController {
    init() {
        super.init(style: .grouped)

        title = "BigDiffer Sandbox"

        form +++ Section("tonyarnold/Differ")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(DifferSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            <<< LabelRow {
                $0.title = "Multi-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(DifferMultiSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            +++ Section("mcudich/HeckelDiff")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(HeckelDiffSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            +++ Section("muukii/DataSources")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(DataSourcesSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(true, animated: animated)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.text = form[section].header?.title
    }
}
