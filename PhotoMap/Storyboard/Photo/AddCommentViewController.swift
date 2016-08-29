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
    
    private var comment = Variable<Link?>(nil)
    
    @IBOutlet private weak var inputTextView: UITextView!
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.rx_text
            .map { !$0.isEmpty }
            .bindTo(doneBarButtonItem.rx_enabled)
            .addDisposableTo(disposeBag)
        
        inputTextView.becomeFirstResponder()
    }
    
    @IBAction private func done(sender: UIBarButtonItem) {
        
        photo.rx_insertComment(content: inputTextView.text)
            .doOnNext { [unowned self] in self.comment.value = $0 }
            .doOnError { [unowned self] error in self.title = "评论发布失败"; print(error) }
            .subscribeCompleted { [unowned self] in self.title = "评论发布成功"
                self.navigationController?.popViewControllerAnimated(true)
            }
            .addDisposableTo(disposeBag)
        
    }
    
    
}
