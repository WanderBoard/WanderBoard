//
//  ImageInfoView.swift
//  WanderBoard
//
//  Created by David Jang on 6/25/24.
//

import UIKit
import SnapKit

protocol ImageInfoViewDelegate: AnyObject {
    func didTapSharePinButton(_ sender: UIButton)
}

class ImageInfoView: UIView {
    
    weak var delegate: ImageInfoViewDelegate?

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

//    private let addressLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 2
//        return label
//    }()

    private let websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.tintColor = .black
        button.contentMode = .scaleAspectFit
        button.isEnabled = false
        return button
    }()

    private let callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        button.tintColor = .black
        button.contentMode = .scaleAspectFit
        button.isEnabled = false
        return button
    }()

    let sharePinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up.circle.fill"), for: .normal)
        button.tintColor = .black
//        button.backgroundColor = .black
        button.contentMode = .scaleAspectFit
        button.isEnabled = true

        return button
    }()

    private var phoneNumber: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = 4

        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(websiteButton)
        addSubview(callButton)
        addSubview(sharePinButton)

        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
//            make.trailing.equalTo(sharePinButton.snp.leading).offset(-10)
        }

        callButton.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.trailing.equalTo(websiteButton.snp.leading).offset(-10)
            make.width.height.equalTo(44)
        }

        websiteButton.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.trailing.equalTo(sharePinButton.snp.leading).offset(-10)
            make.width.height.equalTo(44)
        }

        sharePinButton.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
//            make.leading.equalTo(websiteButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(44)
        }
    }

    private func setupActions() {
        websiteButton.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        websiteButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        callButton.addTarget(self, action: #selector(callPhoneNumber), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        callButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        sharePinButton.addTarget(self, action: #selector(sharePin), for: .touchUpInside)
    }

    func configure(name: String, phone: String, website: String) {
        nameLabel.text = name.isEmpty ? "No Name" : name
//        addressLabel.text = address.isEmpty ? "No Address" : address
        phoneNumber = phone.isEmpty ? "No Phone" : phone
        
        callButton.isEnabled = !phone.isEmpty
        callButton.alpha = phone.isEmpty ? 0.0 : 1.0
        
        websiteButton.isEnabled = !website.isEmpty
        websiteButton.alpha = website.isEmpty ? 0.0 : 1.0
        websiteButton.accessibilityLabel = website
        
        sharePinButton.isEnabled = true
        sharePinButton.alpha = 1.0
    }

    @objc private func openWebsite() {
        if let website = websiteButton.accessibilityLabel, !website.isEmpty {
            var urlString = website
            if !website.lowercased().hasPrefix("http://") && !website.lowercased().hasPrefix("https://") {
                urlString = "http://\(website)"
            }
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Invalid website URL: \(urlString)")
            }
        }
    }

    @objc private func callPhoneNumber() {
        if let phone = phoneNumber, !phone.isEmpty {
            let cleanedPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(cleanedPhoneNumber)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Unable to make a call.")
                }
            }
        } else {
            print("Phone number is not available.")
        }
    }
    
    @objc private func sharePin() {
        delegate?.didTapSharePinButton(sharePinButton)
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform(scaleX: 0.95, y: 0.95))
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform.identity)
    }

    private func animateButton(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.1) {
            button.transform = transform
        }
    }
}
