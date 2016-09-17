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
    
    @IBOutlet weak fileprivate var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_currentIndex
            .asDriver()
            .distinctUntilChanged()
            //            .doOnNext { print("rx_currentIndex", $0) }
            .do(onNext: { [unowned self] in
                let offset = CGPoint(x: CGFloat($0) * self.scrollView.bounds.width, y:0)
                self.scrollView.setContentOffset(offset, animated: false)
            })
            .filter { [unowned self] in self.viewControllers[$0] == nil }
            .drive(onNext: { [unowned self] in self.performSegue(withIdentifier: "ViewController\($0)", sender: $0) })
            .addDisposableTo(disposeBag)
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        print(String(self.dynamicType), #function, segue.identifier)
        let index = sender as! Int
        viewControllers[index] = segue.destination
    }
}

extension DetailController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(String(describing: type(of: self)), #function, scrollView.contentOffset)
        rx_currentIndex.value = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
}

