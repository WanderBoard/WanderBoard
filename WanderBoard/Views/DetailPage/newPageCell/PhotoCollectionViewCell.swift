//
//  PhotoCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/25/24.
//

import UIKit
import SnapKit
import Then

class PhotoCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: PhotoCollectionViewCell.self)
    
    private let scrollView = UIScrollView()
    private let photoImage = UIImageView()
    
    private var currentAmount: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        addPinchGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        photoImage.contentMode = .scaleAspectFill
        photoImage.clipsToBounds = true
        photoImage.layer.cornerRadius = 30
        photoImage.backgroundColor = .black
        photoImage.tintColor = .black
        
        contentView.addSubview(photoImage)
    }
    
    private func setupConstraints() {
        photoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        photoImage.isUserInteractionEnabled = true
        photoImage.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let scale = max(gesture.scale, 1)
            photoImage.transform = CGAffineTransform(scaleX: 1 + currentAmount + (scale - 1), y: 1 + currentAmount + (scale - 1))
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                self.photoImage.transform = .identity
            }, completion: nil)
            currentAmount = 0
        }
    }
    
    func configure(with image: UIImage?, isRepresentative: Bool) {
        photoImage.image = image
    }
}
