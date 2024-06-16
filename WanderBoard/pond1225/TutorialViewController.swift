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
        let page1 = ContentsPageViewController(title: "기록하고 싶은 인상깊은 순간이 있나요?", subTitle: "당신의 추억도, 통장도 소중하니깐.", detailTitle: "여행한 장소와 사진, 느낀 점을 알려주세요. \n  WonderBoard에선 여행 경비도 기록할 수 있어 \n  여행에 사용한 금액 역시 확인 가능합니다.", imageName: "tutorial1", showXButton: true)
        
        let page2 = ContentsPageViewController(title: "사람들의 공유된 순간을 만나보세요!", subTitle: "어디든 갈 수 있어요. ", detailTitle: "지도나 사진을 눌러 다른 사람들의 이야기를 확인해보세요. \n  WonderBoard에서는 세상의 모든 기록을 확인할 수 있습니다.", imageName: "tutorial2", showXButton: true)
        
        let page3 = ContentsPageViewController(title: "지출 내역을 분류하고 관리해요 ", subTitle: "여행 중 소비내역을 한눈에 파악할 수 있어요.", detailTitle: "지출 내역을 입력하면 날짜별로 지출 내역이 기록됩니다. \n 소중한 당신의 통장을 위해 기록해보세요.", imageName: "tutorial3", showXButton: false, showWanderButton: true)
        
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
                pageControl.currentPageIndicatorTintColor = .black
                pageControl.pageIndicatorTintColor = .gray
                pageControl.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(pageControl)
    }
    
    private func makeConstraints() {
        pageControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
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
