//
//  PhotoInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/26/24.
//

import UIKit

protocol PhotoInputCollectionViewCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
}

class PhotoInputCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoInputCollectionViewCell"
    
    weak var delegate: PhotoInputCollectionViewCellDelegate?
    
    var indexPath: IndexPath?
    
    var isRepresentative: Bool = false {
        didSet {
            representativeLabel.isHidden = !isRepresentative
        }
    }
    
    let imageView = UIImageView()
    let addButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    
    let representativeLabel = UILabel().then {
        $0.text = "대표"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.isUserInteractionEnabled = true
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.borderWidth = 1
        if let lightGrayColor = UIColor(named: "lightgray") {
            self.contentView.layer.borderColor = lightGrayColor.cgColor
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        tapGesture.cancelsTouchesInView = false
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(addButton)
        contentView.addSubview(representativeLabel)
        contentView.addSubview(deleteButton)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.lightgray, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 80)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 16
        addButton.isUserInteractionEnabled = false
        addButton.clipsToBounds = true
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        representativeLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(6)
            $0.size.equalTo(CGSize(width: 60, height: 35))
        }
        
        deleteButton.setImage(UIImage(systemName: "minus"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = .lightGray
        deleteButton.layer.cornerRadius = 15
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    func configure(with image: UIImage?, isRepresentative: Bool, indexPath: IndexPath) {
        self.indexPath = indexPath
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            addButton.isHidden = true
            deleteButton.isHidden = false
            self.isRepresentative = isRepresentative
            representativeLabel.isHidden = !isRepresentative
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
            deleteButton.isHidden = true
            representativeLabel.isHidden = true
        }
    }

    @objc func handleImageTap() {
        guard let superview = self.superview as? UICollectionView else { return }
        guard let indexPath = superview.indexPath(for: self) else { return }
        if let galleryCellDelegate = superview.delegate as? GallaryInputCollectionViewCellDelegate {
            galleryCellDelegate.didSelectRepresentativeImage(at: indexPath.item - 1)
        }
    }
    
    @objc func deleteButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteButton(at: indexPath)
    }
}

