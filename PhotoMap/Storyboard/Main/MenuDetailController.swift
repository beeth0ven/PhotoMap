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
    
    @IBOutlet weak private var showMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak private var hideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak private var maskButton: UIButton!
    
    var rx_currentIndex: Variable<Int> {
        return childViewControllerWithType(DetailController)!.rx_currentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rx_showMenuDriver = rx_showMenu
            .asDriver()
            .distinctUntilChanged()
//            .doOnNext { print("rx_showMenu", $0) }
        
        rx_showMenuDriver
            .drive(rx_showMenuObserver)
            .addDisposableTo(disposeBag)
        
        rx_showMenuDriver
            .map { $0 ? UIStatusBarStyle.LightContent : .Default }
            .drive(rx_preferredStatusBarStyle)
            .addDisposableTo(disposeBag)
        
        maskButton.rx_tap
            .asDriver()
            .drive(rx_toogleShowMenuObserver)
            .addDisposableTo(disposeBag)
        
    }
    
    var rx_toogleShowMenuObserver: AnyObserver<Void> {
        
        return UIBindingObserver(UIElement: self, binding: { (selfvc, show) in
            
            selfvc.rx_showMenu.value = !selfvc.rx_showMenu.value
            
        }).asObserver()
    }
    
    private var rx_showMenuObserver: AnyObserver<Bool> {
        
        return UIBindingObserver(UIElement: self, binding: { (selfvc, show) in
            
            selfvc.showMenuConstraint.active = show
            selfvc.hideMenuConstraint.active = !show
            
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
            
            UIView.animateWithDuration(0.3, animations: {
                selfvc.maskButton.alpha = show ? 1 : 0
                selfvc.view.layoutIfNeeded()
            })
            
        }).asObserver()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return _preferredStatusBarStyle
    }
    
    private var _preferredStatusBarStyle = UIStatusBarStyle.Default {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    
    private var rx_preferredStatusBarStyle: AnyObserver<UIStatusBarStyle> {
        return UIBindingObserver(UIElement: self, binding: { (selfvc, style) in
            selfvc._preferredStatusBarStyle = style
        }).asObserver()
    }
}
