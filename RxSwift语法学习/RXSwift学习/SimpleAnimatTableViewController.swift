//
//  SimpleAnimatTableViewController.swift
//  RXSwift学习
//
//  Created by Kagen Zhao on 16/7/29.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SimpleAnimatTableViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Double>>()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var arr = [
            AnimatableSectionModel(model: "First section", items: [1.0, 2.0, 3.0]),
            AnimatableSectionModel(model: "Second section", items: [4.0, 5.0, 6.0]),
            AnimatableSectionModel(model: "Third section", items: [7.0, 8.0, 9.0])
        ]
        let dataSource = self.dataSource;
        let datas = Observable.just(arr)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        dataSource.configureCell = {
            ds, tableView, indexPath, num in
            let cell = tableView.dequeueReusableCellWithIdentifier("identifier", forIndexPath: indexPath)
            cell.textLabel?.text = "\(num)"
            return cell
        }
        dataSource.canEditRowAtIndexPath = {
            ds, indexPath in
            return true
        }
        
        datas.bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected.map {
            ($0, dataSource.itemAtIndexPath($0))
            }.subscribeNext { (indexPath, model) in
                
            }.addDisposableTo(disposeBag)
        tableView.rx_itemDeleted.subscribeNext{
            arr[$0.section].items.removeAtIndex($0.row)
            if arr[$0.section].items.count == 0 {arr.removeAtIndex($0.section)}
            dataSource.tableView(self.tableView, observedEvent: Event.Next(arr))
        }.addDisposableTo(disposeBag)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.redColor()
        label.text = dataSource.sectionAtIndex(section).model ?? ""
        return label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
