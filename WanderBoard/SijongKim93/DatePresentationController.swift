//
//  DatePresentationController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/3/24.
//

import UIKit
import SnapKit
import Then

class DatePresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        return CGRect(x: 0, y: containerView.bounds.height * 0.4, width: containerView.bounds.width, height: containerView.bounds.height * 0.6)
    }
    
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        
        dimmingView.frame = containerView.bounds
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        containerView.insertSubview(dimmingView, at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
        
        presentedView.frame = frameOfPresentedViewInContainerView
        containerView.addSubview(presentedView)
    }
    
    @objc func dimmingViewTapped() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    override func containerViewDidLayoutSubviews() {
        dimmingView.frame = containerView?.bounds ?? CGRect.zero
    }
    
    func shouldRemovePresentersView() -> Bool {
        return false
    }
    
}
