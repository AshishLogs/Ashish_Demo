//
//  HoldingsViewController.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import UIKit
import Combine

final class HoldingsViewController: UIViewController {
    private let viewModel: HoldingsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = AppConstants.UI.cellHeight
        tableView.backgroundColor = AppColors.backgroundColor
        tableView.showsVerticalScrollIndicator = true
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let emptyStateView = EmptyStateView()
    private let errorStateView = ErrorStateView()
    private let collapsibleSummaryView = CollapsibleSummaryView()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["POSITIONS", "HOLDINGS"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 1
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: AppColors.lightGray
        ], for: .normal)
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: AppColors.darkGray
        ], for: .selected)
        control.selectedSegmentTintColor = .clear
        control.backgroundColor = .clear
        control.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        return control
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshHoldings), for: .valueChanged)
        return control
    }()
    
    enum Section: Hashable {
        case main
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Holding> = {
        UITableViewDiffableDataSource<Section, Holding>(tableView: tableView) { [weak self] tableView, indexPath, holding in
            guard let self = self else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: HoldingTableViewCell.reuseIdentifier, for: indexPath) as? HoldingTableViewCell
            cell?.configure(with: holding)
            return cell ?? UITableViewCell()
        }
    }()
    
    init(viewModel: HoldingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        loadHoldings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSegmentedControlUnderline()
    }
    
    private func updateSegmentedControlUnderline() {
        guard let titleView = navigationItem.titleView else { return }
        
        // Remove existing underline views
        titleView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Calculate segment width
        let segmentWidth = segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let underlineX = CGFloat(selectedIndex) * segmentWidth
        let underlineWidth = segmentWidth
        
        // Create underline view
        let underlineView = UIView()
        underlineView.backgroundColor = .systemBlue
        underlineView.tag = 999
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            underlineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: underlineX),
            underlineView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underlineView.widthAnchor.constraint(equalToConstant: underlineWidth),
            underlineView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.cancel()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = nil
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
        
        // Add segmented control to navigation bar
        let containerView = UIView()
        containerView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 220),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        navigationItem.titleView = containerView
        
        // Add underline view for selected segment
        updateSegmentedControlUnderline()
    }
    
    private func loadHoldings() {
        Task { @MainActor in
            await viewModel.loadHoldings()
        }
    }
    
    @objc private func refreshHoldings() {
        Task { @MainActor in
            await viewModel.loadHoldings()
            refreshControl.endRefreshing()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.backgroundColor
        
        tableView.refreshControl = refreshControl
        tableView.register(HoldingTableViewCell.self, forCellReuseIdentifier: HoldingTableViewCell.reuseIdentifier)
        
        view.addSubview(tableView)
        view.addSubview(collapsibleSummaryView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(errorStateView)
        
        emptyStateView.isHidden = true
        errorStateView.isHidden = true
        collapsibleSummaryView.isHidden = true
        collapsibleSummaryView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: collapsibleSummaryView.topAnchor),
            
            collapsibleSummaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collapsibleSummaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collapsibleSummaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func setupBindings() {        
        viewModel.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange(_ state: HoldingsViewModel.ViewState<[Holding]>) {
        switch state {
        case .idle:
            break
            
        case .loading:
            loadingIndicator.startAnimating()
            errorStateView.isHidden = true
            emptyStateView.isHidden = true
            collapsibleSummaryView.isHidden = true
            
        case .loaded(let holdings):
            loadingIndicator.stopAnimating()
            updateSnapshot(with: holdings)
            updateCollapsibleSummary(with: holdings)
            updateEmptyState(holdings.isEmpty)
            
        case .error(let error, let retryAction):
            loadingIndicator.stopAnimating()
            errorStateView.configure(message: error.localizedDescription)
            errorStateView.retryAction = retryAction
            errorStateView.isHidden = false
            emptyStateView.isHidden = true
            collapsibleSummaryView.isHidden = true
        }
    }
    
    private func updateSnapshot(with holdings: [Holding]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Holding>()
        snapshot.appendSections([.main])
        snapshot.appendItems(holdings, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateCollapsibleSummary(with holdings: [Holding]) {
        guard !holdings.isEmpty else {
            collapsibleSummaryView.isHidden = true
            return
        }
        
        collapsibleSummaryView.isHidden = false
        
        let currentValue = holdings.reduce(0.0) { $0 + ($1.ltp * Double($1.quantity)) }
        let totalInvestment = holdings.reduce(0.0) { $0 + ($1.avgPrice * Double($1.quantity)) }
        let todaysPnl = holdings.reduce(0.0) { $0 + (($1.ltp - $1.close) * Double($1.quantity)) }
        let totalPnl = holdings.reduce(0.0) { $0 + $1.pnl }
        
        collapsibleSummaryView.configure(
            currentValue: currentValue,
            totalInvestment: totalInvestment,
            todaysPnl: todaysPnl,
            totalPnl: totalPnl
        )
    }
    
    private func updateEmptyState(_ isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

