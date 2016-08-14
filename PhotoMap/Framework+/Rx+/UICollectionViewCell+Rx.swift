//
//  UICollectionViewCell+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import UIKit
import RxSwift
import RxCocoa

class RxCollectionViewCell: UICollectionViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseDisposeBag = DisposeBag()
    }
    
    private(set) var prepareForReuseDisposeBag = DisposeBag()
}

class RxTableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseDisposeBag = DisposeBag()
    }
    
    private(set) var prepareForReuseDisposeBag = DisposeBag()

}