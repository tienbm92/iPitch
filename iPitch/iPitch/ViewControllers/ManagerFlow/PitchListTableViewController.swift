//
//  PitchListTableViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import FirebaseAuth

class PitchListTableViewController: UITableViewController {
    
    private var pitches = [Pitch]()
    lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 20,
            height: 60)
        label.center = CGPoint(x: self.view.center.x,
            y: self.view.center.y - 100)
        label.text = "NoData".localized
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    var selectedPitch: Pitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PitchesList".localized
        self.tableView.register(UINib.init(nibName: "PitchListCell", bundle: nil),
            forCellReuseIdentifier: kPitchListCellId)
        self.tableView.estimatedRowHeight = 106
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(noDataLabel)
        self.noDataLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchPitch()
    }
    
    private func fetchPitch() {
        WindowManager.shared.showProgressView()
        PitchService.shared.getPitchForManager() { [weak self] (pitches) in
            WindowManager.shared.hideProgressView()
            ImageStore.shared.deleteAllCache()
            if !pitches.isEmpty {
                self?.noDataLabel.isHidden = true
            } else {
                self?.noDataLabel.isHidden = false
            }
            self?.pitches = pitches
            self?.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatePitchId" { 
            guard let createPitchVC = segue.destination
                as? EditPitchViewController else {
                return
            }
            createPitchVC.type = .create
        }
        if segue.identifier == "EditPitchId" { 
            guard let editPitchViewController = segue.destination
                as? EditPitchViewController else {
                    return
            }
            editPitchViewController.pitch = self.selectedPitch
            editPitchViewController.type = .update
        }
        if segue.identifier == "OrdersListId" {
            guard let selectedPitch = sender as? Pitch,
                let pitchDetailVC = segue.destination as? PitchDetailViewController else {
                return
            }
            pitchDetailVC.pitch = selectedPitch
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.directToMainStoryboard()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.logoutAction()
    }
    
    // MARK: TableView DataSource
    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return self.pitches.count
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kPitchListCellId,
            for: indexPath) as? PitchListCell else {
            return UITableViewCell()
        }        
        cell.pitch = self.pitches[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
}

extension PitchListTableViewController: PitchListCellDelegate {
    
    func checkOrder(pitch: Pitch?) {
        guard let pitch = pitch else {
            return
        }
        self.selectedPitch = pitch
        self.performSegue(withIdentifier: "OrdersListId", sender: selectedPitch)
    }
    
    func editPitch(pitch: Pitch?) {
        guard let pitch = pitch else {
            return
        }
        self.selectedPitch = pitch
        self.performSegue(withIdentifier: "EditPitchId", sender: selectedPitch)
    }
}
