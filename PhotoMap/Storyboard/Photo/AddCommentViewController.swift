//
//  AddCommentViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/23.
//
//

import UIKit

class AddCommentViewController: UIViewController {
    
    var photo: Photo!
    
    @IBOutlet private weak var inputTextView: UITextView!
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.rx_text
            .map { !$0.isEmpty }
            .bindTo(doneBarButtonItem.rx_enabled)
            .addDisposableTo(disposeBag)
    }
    
    @IBAction private func done(sender: UIBarButtonItem) {
        
        Link.rx_insertComment(to: photo, content: inputTextView.text)
            .doOnError { [unowned self] error in self.title = "评论发布失败"; print(error) }
            .subscribeCompleted { [unowned self] in self.title = "评论发布成功" }
            .addDisposableTo(disposeBag)
        
    }
}
