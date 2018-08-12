//
//  ViewController.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 06.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import UIKit

enum NotificationKeys: String {
    case isDownloaded = "com.DVDevelopment.isDownloaded"
    case updateImage = "com.DVDevelopment.updateImage"
    case updateRow = "com.DVDevelopment.updateRow"
}

class TableViewController: UITableViewController {
    // MARK: - Public properties
    var viewModel: TableViewModel!
    
    // MARK: - Private properties
    private let reuseIdentifier = "Cell"
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        createObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // disposing of resources
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - TableView data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CustomCell
        
        cell.viewModel = viewModel.cellForRowAt(indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = viewModel.numberOfRowsInSection(indexPath.section) - 1
        
        if indexPath.row == lastItem {
            viewModel.loadNextPage()
        }
    }
    
    
    // MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomCell.cellHeight()
    }
    
    // MARK: - Private methods
    private func setupTableView() {
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = false
        tableView.register(CustomCell.self, forCellReuseIdentifier: reuseIdentifier)
        navigationItem.title = "News"
    }
    
    
    // MARK: - Observers
    private func createObservers() {
        let isDownloaded = Notification.Name(NotificationKeys.isDownloaded.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.updateScreen), name: isDownloaded, object: nil)
        
        let updateRow = Notification.Name(NotificationKeys.updateRow.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.updateRow(notification:)), name: updateRow, object: nil)
    }
    
    @objc private func updateScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
//            let offset = weakSelf.tableView.contentOffset
            weakSelf.tableView.reloadData()
//            weakSelf.tableView.contentOffset = offset
        }
    }
    
    @objc private func updateRow(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            let visibleCells = weakSelf.tableView.visibleCells
            
            weakSelf.tableView.reloadData()
            guard let dictionary = notification.userInfo as? [String:IndexPath], let indexPath = dictionary["indexPath"] else { return }
            for cell in visibleCells {
                if weakSelf.tableView.cellForRow(at: indexPath) == cell {
                    let indexPathList = [indexPath]
                    weakSelf.tableView.reloadRows(at: indexPathList, with: .none)
                }
            }
        }
    }
}
