import Eureka

final class MenuViewController: FormViewController {
    init() {
        super.init(style: .grouped)

        title = "BigDiffer Sandbox"

        form +++ Section("banjun/BigDiffer")
            <<< LabelRow {
                $0.title = "Muti-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(BigDifferMultiSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            } +++ Section("tonyarnold/Differ + workaround")
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
            +++ Section("mcudich/HeckelDiff + workaround")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(HeckelDiffSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            +++ Section("onmyway133/DeepDiff + workaround")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(DeepDiffSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            +++ Section("kazuhiro4949/EditDistance + workaround")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(EditDistanceSingleSectionTableViewController(style: .plain), sender: nil)
                }
                $0.cell.accessoryType = .disclosureIndicator
            }
            +++ Section("ra1028/DifferenceKit + workaround")
            <<< LabelRow {
                $0.title = "Single-Section TableView"
                $0.onCellSelection { [unowned self] _, _ in
                    self.show(DifferenceKitSingleSectionTableViewController(style: .plain), sender: nil)
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
