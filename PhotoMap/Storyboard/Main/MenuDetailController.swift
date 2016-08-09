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
    
    private let disposeBag = DisposeBag()
    
    var rx_currentIndex: Variable<Int> {
        return childViewControllerWithType(DetailController)!.rx_currentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rx_showMenuDriver = rx_showMenu
            .asDriver()
            .distinctUntilChanged()
            .doOnNext { print("rx_showMenu", $0) }
        
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

class DetailController: UIViewController, HasMenuDetailController {
    
    let rx_currentIndex = Variable(0)
    
    var viewControllers = [Int: UIViewController]()
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var toggleMenuBarButtonItem: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_currentIndex
            .asDriver()
            .distinctUntilChanged()
            .doOnNext { print("rx_currentIndex", $0) }
            .doOnNext { [unowned self] in
                let offset = CGPoint(x: CGFloat($0) * self.scrollView.bounds.width, y:0)
                self.scrollView.setContentOffset(offset, animated: false)
            }
            .filter { [unowned self] in self.viewControllers[$0] == nil }
            .driveNext { [unowned self] in self.performSegueWithIdentifier("ViewController\($0)", sender: $0) }
            .addDisposableTo(disposeBag)
        
        toggleMenuBarButtonItem.rx_tap
            .asDriver()
            .drive(menuDetailController!.rx_toogleShowMenuObserver)
            .addDisposableTo(disposeBag)
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(String(self.dynamicType), #function, segue.identifier)
        let index = sender as! Int
        viewControllers[index] = segue.destinationViewController
    }
}

extension DetailController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print(String(self.dynamicType), #function, scrollView.contentOffset)
        rx_currentIndex.value = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
}


protocol HasMenuDetailController {}

extension HasMenuDetailController where Self: UIViewController {
    
    var menuDetailController: MenuDetailController? {
        
        return parentViewControllerWithType(MenuDetailController)
    }
}