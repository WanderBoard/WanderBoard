//
//  PhotoCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/25/24.
//

import UIKit
import SnapKit
import Then

class PhotoCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    static let identifier = String(describing: PhotoCollectionViewCell.self)
    
    private let scrollView = UIScrollView()
    private let photoImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.clipsToBounds = true
        scrollView.layer.cornerRadius = 30
        scrollView.delegate = self
        contentView.addSubview(scrollView)
        
        photoImage.contentMode = .scaleAspectFill
        photoImage.clipsToBounds = true
        photoImage.layer.cornerRadius = 30
        photoImage.backgroundColor = .black
        photoImage.tintColor = .black
        scrollView.addSubview(photoImage)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        photoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(scrollView.snp.height)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
            })
        }
    }
    
    func configure(with image: UIImage?, isRepresentative: Bool) {
        photoImage.image = image
    }
}
