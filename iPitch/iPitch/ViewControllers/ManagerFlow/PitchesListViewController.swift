//
//  PitchesListViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/14/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class PitchesListViewController: UIViewController {

    @IBOutlet weak var pitchesListTableView: UITableView!
    @IBOutlet weak var noPitchLabel: UILabel!
    fileprivate var pitches = [Pitch]()
    var selectedPitch: Pitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PitchesList".localized
        self.pitchesListTableView.register(UINib.init(nibName: "PitchListCell", bundle: nil),
            forCellReuseIdentifier: kPitchListCellId)
        self.pitchesListTableView.estimatedRowHeight = 106
        self.pitchesListTableView.rowHeight = UITableViewAutomaticDimension
        self.noPitchLabel.text = "NoData".localized
        self.noPitchLabel.isHidden = true
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
                self?.noPitchLabel.isHidden = true
            } else {
                self?.noPitchLabel.isHidden = false
            }
            self?.pitches = pitches
            self?.pitchesListTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatePitchId" { 
            guard let createPitchVC = segue.destination
                as? EditPitchViewController else {
                    return
            }
            createPitchVC.type = .create
        } else if segue.identifier == "EditPitchId" { 
            guard let editPitchViewController = segue.destination
                as? EditPitchViewController else {
                    return
            }
            editPitchViewController.pitch = self.selectedPitch
            editPitchViewController.type = .update
        } else if segue.identifier == "OrdersListId" {
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

}

extension PitchesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return self.pitches.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kPitchListCellId,
            for: indexPath) as? PitchListCell else {
            return UITableViewCell()
        }        
        cell.pitch = self.pitches[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}

extension PitchesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
}

extension PitchesListViewController: PitchListCellDelegate {
    
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
