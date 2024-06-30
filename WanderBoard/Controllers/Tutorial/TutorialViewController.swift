//
//  TutorialViewController2.swift
//  indicatorTest
//
//  Created by t2023-m0049 on 6/16/24.
//

import Foundation
import UIKit
import SnapKit

class TutorialViewController: UIPageViewController {
    
    private var pages = [UIViewController]()
    private var initialPage = 0
    private var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        configureUI()
        makeConstraints()
    }
    
    private func setupPages() {
        let page1 = ContentsPageViewController(title: "기록하고 싶은 인상 깊은 순간이 있나요?", subTitle: "당신의 추억도, 통장도 소중하니깐", detailTitle: "일지, 사진, 경비, 친구 \n 이 모든 것을 한 번에 기록하고 공유", imageName: "tutorial1", showXButton: true)
        
        let page2 = ContentsPageViewController(title: "사람들의 공유된 순간을 만나보세요!", subTitle: "멋진 곳, 당신도 갈 수 있어요", detailTitle: "다른 사람의 게시글에서 봤던 아까 그 장소, \n 지도를 통해 현장으로 이동!", imageName: "tutorial2", showXButton: true)
        
        let page3 = ContentsPageViewController(title: "지출 내역을 분류하고 관리해요", subTitle: "여행 중 지출 내역을 한눈에 파악할 수 있어요", detailTitle: "지출 내역 입력 & 날짜별 정리 \n 총 지출 금액 파악 가능", imageName: "tutorial3", showXButton: false, showWanderButton: true)
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
    }
    
    private func configureUI() {
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([pages[initialPage]], direction: .forward, animated: true)
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
        pageControl.currentPageIndicatorTintColor = .font
        pageControl.pageIndicatorTintColor = .lightgray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
    }
    
    private func makeConstraints() {
        pageControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        //라이트그레이-라이트블랙
        let lightGTolightB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        pageControl.pageIndicatorTintColor = lightGTolightB
    }
}

extension TutorialViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        guard currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        guard currentIndex < (pages.count - 1) else { return nil }
        return pages[currentIndex + 1]
    }
}

extension TutorialViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else { return }
        pageControl.currentPage = currentIndex
    }
}
