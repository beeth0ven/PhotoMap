//
//  DetailController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import UIKit
import RxSwift
import RxCocoa

class DetailController: UIViewController, HasMenuDetailController {
    
    let rx_currentIndex = Variable(0)
    
    var viewControllers = [Int: UIViewController]()
    
    @IBOutlet weak private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_currentIndex
            .asDriver()
            .distinctUntilChanged()
            //            .doOnNext { print("rx_currentIndex", $0) }
            .doOnNext { [unowned self] in
                let offset = CGPoint(x: CGFloat($0) * self.scrollView.bounds.width, y:0)
                self.scrollView.setContentOffset(offset, animated: false)
            }
            .filter { [unowned self] in self.viewControllers[$0] == nil }
            .driveNext { [unowned self] in self.performSegueWithIdentifier("ViewController\($0)", sender: $0) }
            .addDisposableTo(disposeBag)
        
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        print(String(self.dynamicType), #function, segue.identifier)
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

