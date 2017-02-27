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
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    private var pitches = [Pitch]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PitchesList".localized
        self.tableView.register(UINib.init(nibName: "PitchListCell", bundle: nil),
            forCellReuseIdentifier: kPitchListCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.fetchPitch()
    }
    
    private func fetchPitch() {
        WindowManager.shared.showProgressView()
        PitchService.shared.getPitchForManager() { [weak self] (pitches) in
            WindowManager.shared.hideProgressView()
            if let currentSelf = self {
                currentSelf.pitches = pitches
                let widthView = currentSelf.view.bounds.size.width
                if currentSelf.pitches.isEmpty {
                    let noDataLabel: UILabel = {
                        let label = UILabel()
                        label.bounds = CGRect(x: 0, y: 0, width: widthView - 20, height: 60)
                        label.center = CGPoint(x: currentSelf.view.center.x,
                            y: currentSelf.view.center.y - 100)
                        label.text = "NoData".localized
                        label.font = UIFont.systemFont(ofSize: 15)
                        label.textAlignment = .center
                        label.textColor = .darkGray
                        label.numberOfLines = 0
                        return label
                    }()
                    currentSelf.view.addSubview(noDataLabel)
                }
                currentSelf.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPitchId" { 
            guard let createPitchVC = segue.destination as? EditPitchViewController else {
                return
            }
            createPitchVC.type = .create
        }
        if segue.identifier == "pitchDetailId" {
            guard let selectedPitch = sender as? Pitch,
                let pitchDetailVC = segue.destination as? PitchDetailViewController else {
                return
            }
            pitchDetailVC.pitch = selectedPitch
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.logoutAction()
    }
    
    // MARK: TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pitches.count
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kPitchListCellId,
            for: indexPath) as? PitchListCell else {
            return UITableViewCell()
        }
        cell.pitchName.text = self.pitches[indexPath.row].name
        if let photoPath = self.pitches[indexPath.row].photoPath {
            cell.pitchImage.fetchImage(for: photoPath, id: self.pitches[indexPath.row].id,
                completion: nil)
        }
        return cell
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPitch = pitches[indexPath.row]
        self.performSegue(withIdentifier: "pitchDetailId", sender: selectedPitch)
    }
    
}
