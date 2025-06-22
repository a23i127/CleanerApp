//
//   HistoryTableViewController.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/18.
//

import Foundation
import Foundation
import UIKit
import Cache

class HistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cashData: [ImageData] = []
    var indexPath: IndexPath?
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cashData = CacheManager.shared.loadCaptureData(forKey: "captureData") ?? []
        historyTableView.reloadData()
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cashData.count)
        return cashData.count
    }
    
    // セルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで設定したセルのIdentifierと一致させる
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let cashObj = cashData[indexPath.row]
        
        if let castingCell = cell as? CashCellData {
            castingCell.configure(cashData: cashObj)
            return castingCell
        } else {
            self.showAlert()
            return cell
        }
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        self.performSegue(withIdentifier: "GotDetailData", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotDetailData" {
            if let nextViewController = segue.destination as? SecondViewController{
                nextViewController.analysData = cashData[self.indexPath!.row]
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "お知らせです", message: "エラーです", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
