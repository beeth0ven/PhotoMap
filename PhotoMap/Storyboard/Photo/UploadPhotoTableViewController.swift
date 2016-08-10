//
//  UploadPhotoTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift

class UploadPhotoTableViewController: UITableViewController {
    
    @IBOutlet weak var photoTitleTextField: UITextField!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ipc = UIImagePickerController()
        ipc.sourceType = UIImagePickerControllerSourceType(rawValue: indexPath.row)!
        ipc.delegate = self
        presentViewController(ipc, animated: true, completion: nil)
    }
        
    private func uploadImage(image: UIImage) {
        guard let photoTitle = photoTitleTextField.text
            where photoTitle.characters.count > 0 else {
            return title = "请输入图片名称."
        }
        
        title = "保存中..."
        
        Photo.rx_insert(title: photoTitle, image: image)
            .doOnError { [unowned self] _ in self.title = "图片发布失败" }
            .subscribeCompleted { [unowned self] in self.title = "图片发布成功" }
            .addDisposableTo(disposeBag)
    }
}

extension UploadPhotoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print(String(self.dynamicType), #function)
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print(String(self.dynamicType), #function)
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        uploadImage(image)
    }
}