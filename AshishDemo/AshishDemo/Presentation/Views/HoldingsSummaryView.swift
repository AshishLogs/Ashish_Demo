//
//  HoldingsSummaryView.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import UIKit

final class HoldingsSummaryView: UIView {
    private let totalPnlLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = AppColors.darkGray
        label.text = "Total P&L"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalPnlValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.secondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(totalPnlLabel)
        containerView.addSubview(totalPnlValueLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: AppConstants.UI.footerHeight),
            
            totalPnlLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppConstants.UI.horizontalPadding),
            totalPnlLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            totalPnlValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppConstants.UI.horizontalPadding),
            totalPnlValueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            totalPnlValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: totalPnlLabel.trailingAnchor, constant: AppConstants.UI.horizontalPadding)
        ])
    }
    
    func configure(totalPnl: Double) {
        let formatter = CurrencyFormatter()
        totalPnlValueLabel.text = formatter.format(totalPnl)
        totalPnlValueLabel.textColor = totalPnl >= 0 ? AppColors.positiveGreen : AppColors.negativeRed
    }
}

