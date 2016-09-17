//
//  UploadPhotoTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UploadPhotoTableViewController: UITableViewController {
    
    var rx_photo: Driver<Photo> {
        return photo.asDriver()
            .skip(1)
            .map { $0! }
    }
    
    fileprivate var photo = Variable<Photo?>(nil)
    
    @IBOutlet weak var photoTitleTextField: UITextField!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ipc = UIImagePickerController()
        ipc.sourceType = UIImagePickerControllerSourceType(rawValue: (indexPath as NSIndexPath).row)!
        ipc.delegate = self
        present(ipc, animated: true, completion: nil)
    }
        
    fileprivate func uploadImage(_ image: UIImage) {
        guard let photoTitle = photoTitleTextField.text
            , photoTitle.characters.count > 0 else {
            return title = "请输入图片名称."
        }
        
        title = "保存中..."
        
        Photo.rx_insert(title: photoTitle, image: image)
            .do(onNext: { [unowned self] in self.photo.value = $0 })
            .do(onError: { [unowned self] _ in self.title = "图片发布失败" })
            .subscribe(onCompleted: { [unowned self] in
                self.title = "图片发布成功";
                _ = self.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(disposeBag)
    }
}

extension UploadPhotoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(String(describing: type(of: self)), #function)
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print(String(describing: type(of: self)), #function)
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
        uploadImage(image)
    }
}
