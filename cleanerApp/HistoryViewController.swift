//
//  History.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/11.
//

import Foundation
import UIKit
import Cache
class HistoryViewController: UICollectionViewController {
    var cashData: [CaptureData] = []
    var indexPath: IndexPath?
    @IBOutlet var historyCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        cashData = CacheManager.shared.loadCaptureData(forKey: "captureData") ?? []
        historyCollectionView.reloadData()
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //今回はとりあえず12とする。（配列に表示させたいデータを入れている場合は配列のデータ数を返せば良い。）
        return cashData.count
    }
    //セルに表示する内容を記載する
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for:  indexPath)
        //セル上のTag(1)とつけたUILabelを生成
        let cashObj = cashData[indexPath.row]
        let castingCell = cell as? CashCellData
        guard let castingCell else {
            self.showAlert()
            return  cell }
        castingCell.configure(cashData: cashObj)
        return cell
    }
    //セルのサイズを指定する処理
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10 // セル間の間隔
        let numberOfItemsPerRow: CGFloat = 4 // 1行に表示するセルの数
        let totalPadding = padding * (numberOfItemsPerRow + 1)//全体の余白を計算
        //Viewの中に表示させるcellの大きさを指定
        let individualWidth = (collectionView.frame.width - totalPadding) / numberOfItemsPerRow
        return CGSize(width: individualWidth, height: individualWidth+20) // 長方形のセル
    }
    //セル選択時の処理
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexPath = indexPath
        self.performSegue(withIdentifier: "GotDetailData", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotDetailData" {
            if let nextViewController = segue.destination as? DetailViewController {
                nextViewController.data = cashData[self.indexPath!.row]
            }
        }
    }
    func showAlert() {
        let alert = UIAlertController(title: "お知らせです", message: "エラーです", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
