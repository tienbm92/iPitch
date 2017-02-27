//
//  PitchListTableViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class PitchListTableViewController: UITableViewController {
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    private let pitchListCellId = "PitchListCellId"
    private var pitchs = [Pitch]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "PitchListCell", bundle: nil),
            forCellReuseIdentifier: self.pitchListCellId)
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.pitchListCellId,
            for: indexPath) as? PitchListCell else {
            return UITableViewCell()
        }
        return cell
    }
    
}
