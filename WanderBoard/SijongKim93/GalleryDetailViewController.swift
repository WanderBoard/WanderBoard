//
//  GalleryDetailViewController.swift
//  WanderBoard
//
//  Created by 김시종 on 6/7/24.
//

import UIKit


class GalleryDetailViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    
    let scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .black
        $0.pageIndicatorTintColor = .lightGray
    }
    
    let closeButton = UIButton().then {
        $0.setTitle("Back", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupScrollView()
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(closeButton)
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        pageControl.numberOfPages = selectedImages.count
        
        for (index, image) in selectedImages.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = 1000 + index
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(600)
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(CGFloat(index) * view.frame.width)
            }
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(selectedImages.count), height: view.frame.height)
    }
}

extension GalleryDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
}