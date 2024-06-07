//
//  PageViewController.swift
//  WanderBoard
//
//  Created by Luz on 5/31/24.
//

import UIKit
import SnapKit
import SwiftUI
import CoreLocation

class PageViewController: UIViewController, CLLocationManagerDelegate {
    var pageViewController: UIPageViewController!
    let pageContent = ["Explore", "My trips", "My page"]
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPVC()
    }
    
    func setupPVC() {
        //UIPageViewController 설정
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        //첫번째 페이지 뷰컨 설정
        if let initialViewController = viewControllerAtIndex(index: 0) {
            pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }
        
        // PageViewController를 부모 뷰에 추가
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func viewControllerAtIndex(index: Int) -> UINavigationController? {
        guard index >= 0 && index < pageContent.count else {
            return nil
        }
        let contentViewController: UIViewController
        if index == 0 {
            contentViewController = ExploreViewController()
        } else if index == 1 {
            contentViewController = MyTripsViewController()
        } else {
            contentViewController = MyPageViewController()
        }
        if let exploreVC = contentViewController as? ExploreViewController {
            exploreVC.pageIndex = index
            exploreVC.pageText = pageContent[index]
        } else if let myTripsVC = contentViewController as? MyTripsViewController {
            myTripsVC.pageIndex = index
            myTripsVC.pageText = pageContent[index]
        } else if let myPageVC = contentViewController as? MyPageViewController {
            myPageVC.pageIndex = index
        }
        
        let navigationController = UINavigationController(rootViewController: contentViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .font
        
        navigationController.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)
        ]
        
        // 하단 선 제거
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = .white.withAlphaComponent(0.9)
        appearance.backgroundEffect = nil
        navigationController.navigationBar.standardAppearance = appearance
        
        //작은 타이틀만 움직일 수 있습니다
//        appearance.titlePositionAdjustment = UIOffset(horizontal: 50, vertical: 0)
//        navigationController.navigationBar.standardAppearance = appearance
        
        return navigationController
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let navigationController = viewController as? UINavigationController,
              let viewController = navigationController.topViewController as? UIViewController & PageIndexed,
              let index = viewController.pageIndex, index > 0 else {
            return nil
        }
        return viewControllerAtIndex(index: index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let navigationController = viewController as? UINavigationController,
              let viewController = navigationController.topViewController as? UIViewController & PageIndexed,
              let index = viewController.pageIndex, index < pageContent.count - 1 else {
            return nil
        }
        return viewControllerAtIndex(index: index + 1)
    }
}
protocol PageIndexed {
    var pageIndex: Int? { get set }
}



