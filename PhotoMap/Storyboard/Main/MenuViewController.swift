//
//  MenuViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import UIKit

class MenuViewController: UIViewController, HasMenuDetailController {
    
    @IBAction func showViewController(sender: UIButton) {
        menuDetailController!.rx_currentIndex.value = sender.tag
        menuDetailController?.rx_showMenu.value = false
    }
    
}
