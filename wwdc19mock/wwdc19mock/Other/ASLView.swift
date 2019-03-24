//
//  ASLView.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 25/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit
import CoreML

public class ASLView: View {
    
    // Aesthetic
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "American Sign Language"
        label.textColor = .white
        label.font = .systemFont(ofSize: 50, weight: .ultraLight)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    var subtitleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ASL"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    
    // Actual Recording Place
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "img_draw_rect"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var previewView: UIView = {
        let previewView = UIView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = .black
        return previewView
    }()
    
    
    
    //  Buttons
    var clearButton: Button = {
        let button = Button(image: nil, title: "Reset", color: UIColor(hex: 0x938581)!)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var predictButton: Button = {
        let button = Button(image: UIImage(named: "Predict"), title: "Predict", color: UIColor(hex: 0x585563)!)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = 16
        return view
    }()
    
    
    
    // Results
    var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 40, weight: .thin)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    var accuracyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    
    
    // Others
    var showAllButton: Button = {
        let button = Button(image: UIImage(named: "Show"), title: "Toggle to Show All Predictions", color: UIColor(hex: 0x232321)!)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override public func setViews() {
        super.setViews()
        
        addSubview(titleLabel)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addSubview(subtitleImageView)
        subtitleImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addSubview(backgroundImageView)
        addSubview(previewView)
        previewView.backgroundColor = .darkGray
        previewView.layer.cornerRadius = 20
        previewView.layer.borderColor = UIColor.yellow.cgColor
        previewView.layer.borderWidth = 2.0
        previewView.layer.masksToBounds = true
        
        buttonsStackView.addArrangedSubview(clearButton)
        buttonsStackView.addArrangedSubview(predictButton)
        
        addSubview(buttonsStackView)
        
        addSubview(resultLabel)
        resultLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addSubview(accuracyLabel)
        accuracyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        showAllButton.alpha = 0
        addSubview(showAllButton)
        showAllButton.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    override public func layoutViews() {
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: preferredPadding * 1.5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        subtitleImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: preferredPadding * 0.5).isActive = true
        subtitleImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        subtitleImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        backgroundImageView.topAnchor.constraint(equalTo: subtitleImageView.bottomAnchor, constant: preferredPadding).isActive = true
        backgroundImageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor).isActive = true
        backgroundImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        previewView.widthAnchor.constraint(equalTo: backgroundImageView.widthAnchor, multiplier: 1).isActive = true
        previewView.heightAnchor.constraint(equalTo: backgroundImageView.heightAnchor, multiplier: 1).isActive = true
        previewView.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor).isActive = true
        
        buttonsStackView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: preferredPadding).isActive = true
        buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        buttonsStackView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        resultLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: preferredPadding).isActive = true
        resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        accuracyLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor).isActive = true
        accuracyLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        accuracyLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        showAllButton.topAnchor.constraint(equalTo: accuracyLabel.bottomAnchor, constant: preferredPadding).isActive = true
        showAllButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        showAllButton.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor).isActive = true
        showAllButton.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor).isActive = true
        showAllButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -preferredPadding).isActive = true
    }
    
}

