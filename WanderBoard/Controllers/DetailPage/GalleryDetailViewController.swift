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
        $0.backgroundColor = UIColor(named: "textColor")
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .font
        $0.pageIndicatorTintColor = .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupScrollView()
        updateColor()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        
        //라이트그레이-다크그레이
        let lightGTodarkG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkgray") : UIColor(named: "lightgray")
        pageControl.pageIndicatorTintColor = lightGTodarkG
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(pageControl)
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        pageControl.numberOfPages = selectedImages.count
        
        let imageHeightRatio: CGFloat = 0.7
        let imageHeight = view.frame.height * imageHeightRatio
        
        for (index, image) in selectedImages.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = 1000 + index
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints {
                $0.width.equalTo(view.frame.width)
                $0.height.equalTo(imageHeight)
                $0.top.equalTo(scrollView).offset(30)
                $0.leading.equalToSuperview().offset(CGFloat(index) * view.frame.width)
            }
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(selectedImages.count), height: scrollView.frame.height)
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
