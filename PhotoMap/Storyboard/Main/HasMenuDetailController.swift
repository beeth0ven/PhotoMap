//
//  HasMenuDetailController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import UIKit
import RxSwift
import RxCocoa

protocol HasMenuDetailController {}

extension HasMenuDetailController where Self: UIViewController {
    
    var menuDetailController: MenuDetailController? {
        
        return parentViewControllerWithType(MenuDetailController)
    }
}


protocol DetailChildViewControllerType {
    var toggleMenuBarButtonItem: UIBarButtonItem! { get }
}

extension DetailChildViewControllerType where Self: HasMenuDetailController, Self: UIViewController {
    
    func rx_bindToggleShowMenu() {
        
        toggleMenuBarButtonItem.rx_tap
            .asDriver()
            .drive(menuDetailController!.rx_toogleShowMenuObserver)
            .addDisposableTo(disposeBag)
    }
}