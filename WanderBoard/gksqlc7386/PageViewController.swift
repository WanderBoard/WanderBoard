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
    
    var pageControlButton: UIHostingController<PageControlButton>!
    private var selectedIndex = 0
    
    private var isScrollEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPVC()
        setupPageControlButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setPageControlButtonVisibility(notification:)), name: .setPageControlButtonVisibility, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setScrollEnabled(notification:)), name: .setScrollEnabled, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .setPageControlButtonVisibility, object: nil)
        NotificationCenter.default.removeObserver(self, name: .setScrollEnabled, object: nil)
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
        
        if let scrollView = pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        }
        
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
        
        return navigationController
    }
    
    func setupPageControlButton() {
        let pageControlButtonView = PageControlButton(onIndexChanged: { [weak self] index in
            self?.navigateToPage(index: index)
        })
        pageControlButton = UIHostingController(rootView: pageControlButtonView)
        addChild(pageControlButton)
        view.addSubview(pageControlButton.view)
        pageControlButton.didMove(toParent: self)
        
        pageControlButton.view.backgroundColor = .clear
        
        pageControlButton.view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(90)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(70)
        }
    }
    
    func navigateToPage(index: Int) {
        guard let currentViewController = pageViewController.viewControllers?.first as? UINavigationController,
              let currentPage = currentViewController.topViewController as? PageIndexed else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = index > currentPage.pageIndex! ? .forward : .reverse
        if let viewController = viewControllerAtIndex(index: index) {
            pageViewController.setViewControllers([viewController], direction: direction, animated: true) { [weak self] _ in
                self?.selectedIndex = index
                if let scrollView = self?.pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
                    let width = scrollView.bounds.width
                    scrollView.contentOffset = CGPoint(x: width, y: 0)
                }
                NotificationCenter.default.post(name: .didChangePage, object: nil, userInfo: ["selectedIndex": index])
            }
        }
    }
    
    @objc func setPageControlButtonVisibility(notification: Notification) {
        if let hidden = notification.userInfo?["hidden"] as? Bool {
            pageControlButton.view.isHidden = hidden
        }
    }
    
    @objc func setScrollEnabled(notification: Notification) {
        if let isEnabled = notification.userInfo?["isEnabled"] as? Bool {
            isScrollEnabled = isEnabled
        }
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let scrollView = gestureRecognizer.view as? UIScrollView {
            let translation = gestureRecognizer.translation(in: scrollView)
            
            // 네비게이션 이동 시 스크롤 비활성화
            if !isScrollEnabled {
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
                return
            }

            // 첫 번째 페이지에서 왼쪽으로 스크롤할 때 스크롤을 막음
            if selectedIndex == 0 && translation.x > 0 {
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
            }
            // 마지막 페이지에서 오른쪽으로 스크롤할 때 스크롤을 막음
            else if selectedIndex == pageContent.count - 1 && translation.x < 0 {
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
            }
        }
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let viewController = pageViewController.viewControllers?.first as? UINavigationController,
           let pageIndexed = viewController.topViewController as? PageIndexed, let pageIndex = pageIndexed.pageIndex {
            selectedIndex = pageIndex
            NotificationCenter.default.post(name: .didChangePage, object: nil, userInfo: ["selectedIndex": selectedIndex])
        }
    }
}

protocol PageIndexed {
    var pageIndex: Int? { get set }
}

extension Notification.Name {
    static let setPageControlButtonVisibility = Notification.Name("setPageControlButtonVisibility")
    static let didChangePage = Notification.Name("didChangePage")
    static let setScrollEnabled = Notification.Name("setScrollEnabled")
}



