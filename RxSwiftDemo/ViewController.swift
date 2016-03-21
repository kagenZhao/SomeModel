//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/13.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBlocking


class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modes = ["aaaaaaa", "bbbbbbbb", "ccccccccc"]
        let items = Observable.just(modes)
        
        items
            .bindTo(tableView.rx_itemsWithCellIdentifier("MyCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .map { indexPath in
                return (indexPath, modes[indexPath.row])
            }
            .subscribeNext { indexPath, model in
                print("\(model) in \(indexPath)")
            }
            .addDisposableTo(disposeBag)
        
        
    }
}

