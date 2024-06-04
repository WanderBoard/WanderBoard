//
//  DateViewController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/3/24.
//

import UIKit

protocol DateViewControllerDelegate: AnyObject {
    func didPickDates(startDate: Date, endDate: Date)
}

class DateViewController: UIViewController {
    
    weak var delegate: DateViewControllerDelegate?
    
    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("Cancel", for: .normal)
    }
    
    let doneButton = UIButton(type: .system).then {
        $0.setTitle("Done", for: .normal)
    }
    
    let topButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let startDateLabel = UILabel().then {
        $0.text = "출발 날짜"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .left
    }
    
    let endDateLabel = UILabel().then {
        $0.text = "도착 날짜"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .left
    }
    
    let startDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let endDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        actionButton()
        
        view.backgroundColor = .white
        
    }
    
    func setupUI() {
        view.addSubview(topButtonStackView)
        
        topButtonStackView.addArrangedSubview(cancelButton)
        topButtonStackView.addArrangedSubview(doneButton)
        
        view.addSubview(startDateLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        
        topButtonStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        startDateLabel.snp.makeConstraints {
            $0.top.equalTo(topButtonStackView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
        }
        
        startDatePicker.snp.makeConstraints {
            $0.top.equalTo(startDateLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(150)
        }
        
        endDateLabel.snp.makeConstraints {
            $0.top.equalTo(startDatePicker.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
        }
        
        endDatePicker.snp.makeConstraints {
            $0.top.equalTo(endDateLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(10)
            $0.height.equalTo(150)
        }
    }
    
    func actionButton() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        delegate?.didPickDates(startDate: startDate, endDate: endDate)
        dismiss(animated: true, completion: nil)
    }
}
