//
//  AddCommentViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/23.
//
//

import UIKit
import RxSwift
import RxCocoa

class AddCommentViewController: UIViewController {
    
    var photo: Photo!
    
    var rx_comment: Driver<Link> {
        return comment.asDriver()
            .skip(1)
            .map { $0! }
    }
    
    fileprivate var comment = Variable<Link?>(nil)
    
    @IBOutlet fileprivate weak var inputTextView: UITextView!
    @IBOutlet fileprivate weak var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.rx.textInput.text
            .map { !$0.isEmpty }
            .bindTo(doneBarButtonItem.rx.enabled)
            .addDisposableTo(disposeBag)
        
        inputTextView.becomeFirstResponder()
    }
    
    @IBAction fileprivate func done(_ sender: UIBarButtonItem) {
        
        photo.rx_insertComment(content: inputTextView.text)
            .do(onNext: { [unowned self] in self.comment.value = $0 })
            .do(onError: { [unowned self] error in self.title = "评论发布失败"; print(error) })
            .subscribe(onCompleted: { [unowned self] in self.title = "评论发布成功"
                _ = self.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
}
