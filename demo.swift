import UIKit

class FocusViewController: UIViewController {
    
    enum FocusCellType: Int, CaseIterable {
        case progress = 0
        case hint
        case data
    }
    
    private let tableView = UITableView()
    
    private var type: FocusType {
        set {
            Settings.defaultFocusType = newValue
        }
        get {
            return Settings.defaultFocusType
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Start focusing".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configTableView()
        initLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        setCountDownGoal(animated: false)
    }
    
    private func configTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProgressTableViewCell.self, forCellReuseIdentifier: ProgressTableViewCell.identifier)
        tableView.register(FocusHintTableViewCell.self, forCellReuseIdentifier: FocusHintTableViewCell.identifier)
        tableView.register(FocusDataTableViewCell.self, forCellReuseIdentifier: FocusDataTableViewCell.identifier)
        
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .healthBackgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 260
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    @objc func updateTableView() {
        tableView.reloadData()
    }
}

extension FocusViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FocusCellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellType = FocusCellType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch cellType {
        case .progress:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewCell.identifier, for: indexPath) as! ProgressTableViewCell
            cell.delegate = self
            return cell
        case .hint:
            let cell = tableView.dequeueReusableCell(withIdentifier: FocusHintTableViewCell.identifier, for: indexPath) as! FocusHintTableViewCell
            return cell
        case .data:
            let cell = tableView.dequeueReusableCell(withIdentifier: FocusDataTableViewCell.identifier, for: indexPath) as! FocusDataTableViewCell
            cell.config(allData: Focus.db)
            return cell
        }
    }
}

extension FocusViewController: UITableViewDelegate {
    
}

extension FocusViewController: ProgressTableViewCellDelegate {
    func handleGoalChanged(_ cell: ProgressTableViewCell, hours: Int, mins: Int) {
        let timeInterval: TimeInterval = TimeInterval(integerLiteral: Int64(hours * 60 * 60 + mins * 60))
        
        
        dprint("\ntimeInterval: \(timeInterval)\n")
        
        type = .countdown(goal: timeInterval)
        cell.setTimeInterval(timeInterval, animated: true)
        cell.setStartButtonEnabled(goal: timeInterval)
    }
    
    func startButtonDidPress(_ cell: ProgressTableViewCell) {
        FocusProgressViewController.present(sender: self)
    }
}

extension FocusViewController {
    private func setCountDownGoal(goal: TimeInterval = Settings.defaultFocusGoal1, animated: Bool) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProgressTableViewCell
        type = .countdown(goal: goal)
        cell.setTimeInterval(Settings.defaultFocusGoal, animated: animated)
        cell.setStartButtonEnabled(goal: goal)
    }
}
