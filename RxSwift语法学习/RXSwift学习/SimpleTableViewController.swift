//
//  SimpleTableViewController.swift
//  RXSwift学习
//
//  Created by Kagen Zhao on 16/7/28.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SimpleTableViewController: UIViewController, UITableViewDelegate {
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()
    let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataSource = self.dataSource
        let datas = Observable.just([
            SectionModel(model: "First section", items: [1.0, 2.0, 3.0]),
            SectionModel(model: "Second section", items: [1.0, 2.0, 3.0]),
            SectionModel(model: "Third section", items: [1.0, 2.0, 3.0])
            ])
        
        tableView .registerClass(UITableViewCell.self, forCellReuseIdentifier: "indentifier")
        dataSource.configureCell = {
            ds, tableview, indexPath, num in
            let cell = tableview.dequeueReusableCellWithIdentifier("indentifier", forIndexPath: indexPath)
            cell.textLabel?.text = "\(num)"
            return cell
        }
        
        datas.bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected.map {
            ($0, dataSource.itemAtIndexPath($0))
        }.subscribeNext { (indexPath, model) in
            
        }.addDisposableTo(disposeBag)
        
        let _ = Observable<Int>.timer(0, period: 3, scheduler: MainScheduler.instance)
        .subscribeNext { (i) in
            print(i)
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.redColor()
        label.text = dataSource.sectionAtIndex(section).model ?? ""
        return label
    }
}
