//
//  FlatVariable.swift
//  Networking
//
//  Created by luojie on 16/8/26.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FlatVariable<Element> {
    
    fileprivate let _subject: BehaviorSubject<Element?>
    fileprivate var _seed: Observable<Element>
    fileprivate var _disposeBag: DisposeBag!

    init(_ seed: Observable<Element>) {
        _seed = seed
        _subject = BehaviorSubject(value: nil)
        refresh()
    }
    
    var value: Element! {
        get {
            do {
               return try _subject.value()
            } catch let error {
                print(error)
                return nil
            }
        }
        set(newValue) {
            _subject.on(.next(newValue))
        }
    }
    
    func refresh() {
        
        _disposeBag = DisposeBag()
        
        _seed
            .do(onError: { [unowned self] in self._subject.onError($0) })
            .subscribe(onNext: { [unowned self] in self._subject.onNext($0) })
            .addDisposableTo(_disposeBag)
    }
    
    func asObservable() -> Observable<Element> {
        return _subject
            .filter {
                switch $0 {
                case .some:
                    return true
                case .none:
                    return false
                }
            }
            .map { $0! }
    }
    
}

extension Observable {
    
    func asFlatVariable() -> FlatVariable<Element> {
        return FlatVariable(self)
    }
}
