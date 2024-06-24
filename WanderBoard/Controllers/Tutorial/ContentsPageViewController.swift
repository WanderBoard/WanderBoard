//
//  ViewController.swift
//  indicatorTest
//
//  Created by t2023-m0049 on 6/16/24.
//

import UIKit
import SnapKit

class ContentsPageViewController: UIViewController {
    
    private var stackView: UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    private var subTitleLabel: UILabel = {
        
        let subTitleLabel = UILabel()
        subTitleLabel.font = .preferredFont(forTextStyle: .body)
        subTitleLabel.font = .boldSystemFont(ofSize: 15)
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        
        return subTitleLabel
    }()
    
    private var detailTitleLabel: UILabel = {
        
        let detailTitleLabel = UILabel()
        detailTitleLabel.font = .preferredFont(forTextStyle: .body)
        detailTitleLabel.font = .systemFont(ofSize: 13)
        detailTitleLabel.textAlignment = .center
        detailTitleLabel.numberOfLines = 0
        
        return detailTitleLabel
    }()
    
    private var imageView = UIImageView()
    private let backImage = UIImageView().then(){
        $0.image = UIImage(named: "bImage")
    }
    private var showXButton: Bool
    private var showWanderButton: Bool
    
    private var xButton: UIButton = {
        let xButton = UIButton(type: .system)
        xButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        xButton.tintColor = .lightGray
        
        return xButton
    }()
    
    private var wanderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Let's Wander!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(title: String, subTitle: String, detailTitle: String, imageName: String, showXButton: Bool, showWanderButton: Bool = false) {
        self.showXButton = showXButton
        self.showWanderButton = showWanderButton
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        subTitleLabel.text = subTitle
        setDetailTitle(detailTitle)
        imageView.image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureUI()
        makeConstraints()
        setGradient()
    }
    
    
    private func configureUI() {
        
        imageView.contentMode = .scaleAspectFill
        view.addSubview(backImage)
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(detailTitleLabel)
        view.addSubview(imageView)
        
        if showXButton {
            view.addSubview(xButton)
        }
        
        if showWanderButton {
            view.addSubview(wanderButton)
        }
        
        xButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        wanderButton.addTarget(self, action: #selector(wanderButtonTapped), for: .touchUpInside)

    }
    
    private func setDetailTitle(_ detailTitle: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        let attributedString = NSAttributedString(
            string: detailTitle,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 13)
            ]
        )
        detailTitleLabel.attributedText = attributedString
    }
    
    
    private func makeConstraints() {
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            $0.width.equalToSuperview().inset(20)

        }
        
        if showXButton {
            xButton.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
                $0.trailing.equalToSuperview().offset(-20)
                $0.width.height.equalTo(30)
            }
        }
        
        if showWanderButton {
            wanderButton.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(235)
                $0.height.equalTo(50)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.top)
            $0.centerX.equalToSuperview()
            
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(stackView.snp.width)
        }
        
        detailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(stackView.snp.width)
            $0.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(view).multipliedBy(0.78)
        }
        backImage.snp.makeConstraints(){
            $0.height.equalTo(view).multipliedBy(0.7)
            $0.horizontalEdges.equalTo(view)
            $0.bottom.equalTo(view)
        }
    }
    
    func setGradient() {
        let maskedView = UIView(frame: CGRect(x: 0, y: ( view.frame.height - 150), width: view.frame.height, height: 150))
        let gradientLayer = CAGradientLayer()
        
        maskedView.backgroundColor = view.backgroundColor
        gradientLayer.frame = maskedView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.7), UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 0.5, 0.9, 1]
        maskedView.layer.mask = gradientLayer
        view.addSubview(maskedView)
        maskedView.isUserInteractionEnabled = false
    }
    
    @objc private func xButtonTapped() {
        let alert = UIAlertController(title: nil, message: "정말 튜토리얼을 종료하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            let nextVC = PageViewController()
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true)

        }))
        alert.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func wanderButtonTapped() {
        let nextVC = PageViewController()
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
    }
}
