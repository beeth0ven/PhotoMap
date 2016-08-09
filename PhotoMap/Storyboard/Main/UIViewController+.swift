//
//  UIViewController+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import UIKit

extension UIViewController {
    /**
     Return a viewController's parentViewController which is a given Type, Usage:
     ```swift
     return viewController.parentViewControllerWithType(LoginContainerViewController)
     ```
     Above code shows how to get viewController's parent LoginContainerViewController
     */
    func parentViewControllerWithType<VC: UIViewController>(type: VC.Type) -> VC? {
        var parentViewController = self.parentViewController
        while parentViewController != nil {
            if let viewController = parentViewController as? VC {
                return viewController
            }
            parentViewController = parentViewController!.parentViewController
        }
        return nil
    }
    
    /**
     Return a viewController's childViewController which is a given Type, Usage:
     ```swift
     return viewController.childViewControllerWithType(QQPlayerViewController)
     ```
     Above code shows how to get viewController's child QQPlayerViewController
     */
    func childViewControllerWithType<ViewController: UIViewController>(type: ViewController.Type) -> ViewController? {
        /**
         recursion to get childViewController.
         here is exmple to show the search order number:
         rootViewController:                           0
         childViewControllers:                         1         5         9
         childViewControllers's childViewControllers:  2 3 4     6 7 8     10 11 12
         */
        for childViewController in childViewControllers {
            if let viewController = childViewController as? ViewController {
                return viewController
            }
            
            if let viewController = childViewController.childViewControllerWithType(ViewController) {
                return viewController
            }
        }
        return  nil
    }
    
}
