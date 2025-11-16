//
//  CollapsibleSummaryView.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import UIKit

final class CollapsibleSummaryView: UIView {
    var isExpanded: Bool = false {
        didSet {
            updateExpandedState()
            onExpansionChanged?(isExpanded)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        view.layer.cornerRadius = AppConstants.UI.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = AppConstants.UI.shadowRadius
        view.layer.shadowOpacity = AppConstants.UI.shadowOpacity
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collapsedContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expandedContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collapsedTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = AppColors.darkGray
        label.text = "Profit & Loss*"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collapsedCaretLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.darkGray
        label.text = "^"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collapsedValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentValueRow: SummaryRowView = {
        let view = SummaryRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalInvestmentRow: SummaryRowView = {
        let view = SummaryRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let todaysPnlRow: SummaryRowView = {
        let view = SummaryRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalPnlRow: SummaryRowView = {
        let view = SummaryRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupHeightConstraint()
        setupUI()
        setupTapGesture()
    }
    
    private func setupHeightConstraint() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 68)
        heightConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(collapsedContentView)
        containerView.addSubview(expandedContentView)
        
        collapsedContentView.isUserInteractionEnabled = true
        expandedContentView.isUserInteractionEnabled = true
        
        collapsedContentView.addSubview(collapsedTitleLabel)
        collapsedContentView.addSubview(collapsedCaretLabel)
        collapsedContentView.addSubview(collapsedValueLabel)
        
        expandedContentView.addSubview(currentValueRow)
        expandedContentView.addSubview(totalInvestmentRow)
        expandedContentView.addSubview(separatorView)
        expandedContentView.addSubview(todaysPnlRow)
        expandedContentView.addSubview(totalPnlRow)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collapsedContentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            collapsedContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppConstants.UI.horizontalPadding),
            collapsedContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppConstants.UI.horizontalPadding),
            collapsedContentView.heightAnchor.constraint(equalToConstant: 44),
            
            collapsedTitleLabel.leadingAnchor.constraint(equalTo: collapsedContentView.leadingAnchor),
            collapsedTitleLabel.centerYAnchor.constraint(equalTo: collapsedContentView.centerYAnchor),
            
            collapsedCaretLabel.leadingAnchor.constraint(equalTo: collapsedTitleLabel.trailingAnchor, constant: 4),
            collapsedCaretLabel.centerYAnchor.constraint(equalTo: collapsedContentView.centerYAnchor),
            
            collapsedValueLabel.trailingAnchor.constraint(equalTo: collapsedContentView.trailingAnchor),
            collapsedValueLabel.centerYAnchor.constraint(equalTo: collapsedContentView.centerYAnchor),
            collapsedValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: collapsedCaretLabel.trailingAnchor, constant: 16),
            
            expandedContentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            expandedContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppConstants.UI.horizontalPadding),
            expandedContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppConstants.UI.horizontalPadding),
            expandedContentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            expandedContentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            currentValueRow.topAnchor.constraint(equalTo: expandedContentView.topAnchor, constant: 8),
            currentValueRow.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor),
            currentValueRow.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor),
            currentValueRow.heightAnchor.constraint(equalToConstant: 24),
            
            totalInvestmentRow.topAnchor.constraint(equalTo: currentValueRow.bottomAnchor, constant: 12),
            totalInvestmentRow.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor),
            totalInvestmentRow.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor),
            totalInvestmentRow.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.topAnchor.constraint(equalTo: totalInvestmentRow.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            todaysPnlRow.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            todaysPnlRow.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor),
            todaysPnlRow.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor),
            todaysPnlRow.heightAnchor.constraint(equalToConstant: 24),
            
            totalPnlRow.topAnchor.constraint(equalTo: todaysPnlRow.bottomAnchor, constant: 12),
            totalPnlRow.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor),
            totalPnlRow.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor),
            totalPnlRow.heightAnchor.constraint(equalToConstant: 24),
            totalPnlRow.bottomAnchor.constraint(equalTo: expandedContentView.bottomAnchor, constant: -8)
        ])
        
        // Set initial state
        collapsedContentView.isHidden = false
        expandedContentView.isHidden = true
        collapsedContentView.alpha = 1
        expandedContentView.alpha = 0
        
        // Ensure expanded content rows are not hidden initially
        currentValueRow.isHidden = false
        totalInvestmentRow.isHidden = false
        separatorView.isHidden = false
        todaysPnlRow.isHidden = false
        totalPnlRow.isHidden = false
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        containerView.isUserInteractionEnabled = true
        collapsedContentView.isUserInteractionEnabled = true
        expandedContentView.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        isExpanded.toggle()
    }
    
    private func updateExpandedState() {
        let targetHeight: CGFloat = isExpanded ? 220 : 68
        
        // Show the content view that should be visible before animation
        if isExpanded {
            expandedContentView.isHidden = false
            expandedContentView.alpha = 0
            // Ensure all subviews are visible and properly configured
            currentValueRow.isHidden = false
            currentValueRow.alpha = 1
            totalInvestmentRow.isHidden = false
            totalInvestmentRow.alpha = 1
            separatorView.isHidden = false
            separatorView.alpha = 1
            todaysPnlRow.isHidden = false
            todaysPnlRow.alpha = 1
            totalPnlRow.isHidden = false
            totalPnlRow.alpha = 1
        } else {
            collapsedContentView.isHidden = false
            collapsedContentView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.heightConstraint.constant = targetHeight
            self.collapsedContentView.alpha = self.isExpanded ? 0 : 1
            self.expandedContentView.alpha = self.isExpanded ? 1 : 0
            self.collapsedCaretLabel.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
            self.expandedContentView.layoutIfNeeded()
        } completion: { _ in
            // Hide the content view that should not be visible after animation
            self.collapsedContentView.isHidden = self.isExpanded
            self.expandedContentView.isHidden = !self.isExpanded
        }
    }
    
    var onExpansionChanged: ((Bool) -> Void)?
    
    func configure(
        currentValue: Double,
        totalInvestment: Double,
        todaysPnl: Double,
        totalPnl: Double
    ) {
        let formatter = CurrencyFormatter()
        
        let totalPnlPercentage = totalInvestment > 0 ? (totalPnl / totalInvestment) * 100 : 0
        let totalPnlFormatted = formatter.format(totalPnl)
        let totalPnlText = "\(totalPnlFormatted) (\(String(format: "%.2f", abs(totalPnlPercentage)))%)"
        
        collapsedValueLabel.text = totalPnlText
        collapsedValueLabel.textColor = totalPnl >= 0 ? AppColors.positiveGreen : AppColors.negativeRed
        
        // Configure expanded content rows
        currentValueRow.configure(label: "Current value*", value: formatter.format(currentValue), valueColor: AppColors.darkGray)
        currentValueRow.isHidden = false
        currentValueRow.alpha = 1
        
        totalInvestmentRow.configure(label: "Total investment*", value: formatter.format(totalInvestment), valueColor: AppColors.darkGray)
        totalInvestmentRow.isHidden = false
        totalInvestmentRow.alpha = 1
        
        separatorView.isHidden = false
        separatorView.alpha = 1
        
        let todaysPnlText = formatter.format(todaysPnl)
        todaysPnlRow.configure(label: "Today's PNL*", value: todaysPnlText, valueColor: todaysPnl >= 0 ? AppColors.positiveGreen : AppColors.negativeRed)
        todaysPnlRow.isHidden = false
        todaysPnlRow.alpha = 1
        
        totalPnlRow.configure(label: "Total PNL*", value: totalPnlText, valueColor: totalPnl >= 0 ? AppColors.positiveGreen : AppColors.negativeRed, showChevron: true)
        totalPnlRow.isHidden = false
        totalPnlRow.alpha = 1
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
}

final class SummaryRowView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppColors.positiveGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.positiveGreen
        label.text = "→"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.darkGray
        label.text = "⌄"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        addSubview(arrowLabel)
        addSubview(chevronLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            arrowLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            arrowLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            chevronLabel.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: 4),
            chevronLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: chevronLabel.trailingAnchor, constant: 16)
        ])
    }
    
    func configure(label: String, value: String, valueColor: UIColor, showChevron: Bool = false) {
        self.label.text = label
        self.valueLabel.text = value
        self.valueLabel.textColor = valueColor
        self.chevronLabel.isHidden = !showChevron
    }
}

