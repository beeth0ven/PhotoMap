//
//  MenuDetailController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import UIKit
import RxSwift
import RxCocoa

class MenuDetailController: UIViewController {
    
    let rx_showMenu = Variable(false)
    
    @IBOutlet weak fileprivate var showMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var hideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var maskButton: UIButton!
    
    var rx_currentIndex: Variable<Int> {
        return childViewControllerWithType(DetailController.self)!.rx_currentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rx_showMenuDriver = rx_showMenu
            .asDriver()
            .distinctUntilChanged()
//            .do(onNext: { print("rx_showMenu", $0) }
        
        rx_showMenuDriver
            .drive(rx_showMenuObserver)
            .addDisposableTo(disposeBag)
        
        rx_showMenuDriver
            .map { $0 ? UIStatusBarStyle.lightContent : .default }
            .drive(rx_preferredStatusBarStyle)
            .addDisposableTo(disposeBag)
        
        maskButton.rx.tap
            .asDriver()
            .drive(rx_toogleShowMenuObserver)
            .addDisposableTo(disposeBag)
        
    }
    
    var rx_toogleShowMenuObserver: AnyObserver<Void> {
        
        return UIBindingObserver(UIElement: self, binding: { (selfvc, show) in
            
            selfvc.rx_showMenu.value = !selfvc.rx_showMenu.value
            
        }).asObserver()
    }
    
    fileprivate var rx_showMenuObserver: AnyObserver<Bool> {
        
        return UIBindingObserver(UIElement: self, binding: { (selfvc, show) in
            
            selfvc.showMenuConstraint.isActive = show
            selfvc.hideMenuConstraint.isActive = !show
            
//            UIView.animateWithDuration(
//                0.3,
//                delay: 0,
//                usingSpringWithDamping: 0.7,
//                initialSpringVelocity: 1,
//                options: [],
//                animations: {
//                    selfvc.maskButton.alpha = show ? 1 : 0
//                    selfvc.view.layoutIfNeeded()
//                },
//                completion: nil
//            )
            
            UIView.animate(withDuration: 0.3, animations: {
                selfvc.maskButton.alpha = show ? 1 : 0
                selfvc.view.layoutIfNeeded()
            })
            
        }).asObserver()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return _preferredStatusBarStyle
    }
    
    fileprivate var _preferredStatusBarStyle = UIStatusBarStyle.default {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    
    fileprivate var rx_preferredStatusBarStyle: AnyObserver<UIStatusBarStyle> {
        return UIBindingObserver(UIElement: self, binding: { (selfvc, style) in
            selfvc._preferredStatusBarStyle = style
        }).asObserver()
    }
}
