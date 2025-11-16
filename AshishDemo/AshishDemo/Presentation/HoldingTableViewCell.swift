//
//  HoldingTableViewCell.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import UIKit

final class HoldingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "HoldingTableViewCell"
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.symbol
        label.textColor = AppColors.symbolColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.quantity
        label.textColor = AppColors.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ltpLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.ltp
        label.textColor = AppColors.darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pnlLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.pnl
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppConstants.UI.stackViewSpacing
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppConstants.UI.stackViewSpacing
        stack.alignment = .trailing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.separatorGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        quantityLabel.attributedText = nil
        ltpLabel.attributedText = nil
        pnlLabel.attributedText = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = AppColors.cardBackground
        
        leftStackView.addArrangedSubview(symbolLabel)
        leftStackView.addArrangedSubview(quantityLabel)
        
        rightStackView.addArrangedSubview(ltpLabel)
        rightStackView.addArrangedSubview(pnlLabel)
        
        contentView.addSubview(leftStackView)
        contentView.addSubview(rightStackView)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            leftStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppConstants.UI.verticalPadding),
            leftStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppConstants.UI.horizontalPadding),
            leftStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppConstants.UI.verticalPadding),
            leftStackView.trailingAnchor.constraint(lessThanOrEqualTo: rightStackView.leadingAnchor, constant: -AppConstants.UI.horizontalPadding),
            
            rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppConstants.UI.verticalPadding),
            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppConstants.UI.horizontalPadding),
            rightStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppConstants.UI.verticalPadding),
            rightStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: AppConstants.UI.rightStackMinWidth),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: AppConstants.UI.separatorHeight)
        ])
    }
    
    func configure(with holding: Holding) {
        symbolLabel.text = holding.symbol.uppercased()
        
        let quantityAttributed = NSMutableAttributedString()
        quantityAttributed.append(NSAttributedString(
            string: "NET QTY: ",
            attributes: [
                .font: AppFonts.quantity,
                .foregroundColor: AppColors.lightGray
            ]
        ))
        quantityAttributed.append(NSAttributedString(
            string: "\(holding.quantity)",
            attributes: [
                .font: AppFonts.quantityValue,
                .foregroundColor: AppColors.darkGray
            ]
        ))
        quantityLabel.attributedText = quantityAttributed
        
        let formatter = CurrencyFormatter()
        let ltpFormatted = formatter.format(holding.ltp)
        let ltpAttributed = NSMutableAttributedString()
        ltpAttributed.append(NSAttributedString(
            string: "LTP: ",
            attributes: [
                .font: AppFonts.ltp,
                .foregroundColor: AppColors.lightGray
            ]
        ))
        ltpAttributed.append(NSAttributedString(
            string: ltpFormatted,
            attributes: [
                .font: AppFonts.ltpValue,
                .foregroundColor: AppColors.symbolColor
            ]
        ))
        ltpLabel.attributedText = ltpAttributed
        
        let pnl = holding.pnl
        let pnlFormatted = formatter.format(pnl)
        let pnlAttributed = NSMutableAttributedString()
        pnlAttributed.append(NSAttributedString(
            string: "P&L: ",
            attributes: [
                .font: AppFonts.pnl,
                .foregroundColor: AppColors.lightGray
            ]
        ))
        pnlAttributed.append(NSAttributedString(
            string: pnlFormatted,
            attributes: [
                .font: AppFonts.pnlValue,
                .foregroundColor: pnl >= 0 ? AppColors.positiveGreen : AppColors.negativeRed
            ]
        ))
        pnlLabel.attributedText = pnlAttributed
    }
}

