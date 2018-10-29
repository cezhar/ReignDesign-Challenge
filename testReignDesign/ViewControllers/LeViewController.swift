//
//  ViewController.swift
//  testReignDesign
//
//  Created by Cezhar Arévalo on 10/28/18.
//  Copyright © 2018 TIANDGI. All rights reserved.
//

import UIKit
import Alamofire

class leCell: UITableViewCell{
    @IBOutlet var title:UILabel!
    @IBOutlet var author:UILabel!
}

class LeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var leHits: [Hit] = Array()
    @IBOutlet var leTable: UITableView!
    let cellReuseIdentifier = "cell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leHits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.leTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! leCell
        let leHit = leHits[indexPath.row]
        cell.author.text = "\(leHit.author) -  \(leHit.createdAt)"
        if leHit.title == nil || (leHit.title?.isEmpty)!{
            cell.title.text = leHit.storyTitle
        }
        else{
            cell.title.text = leHit.title!
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        leTable.dataSource = self
        leTable.delegate = self
        fetchAllRooms(){
            response in
            if let leHitsResults : [Hit] = response{
                self.leHits.removeAll()
                self.leHits.append(contentsOf:leHitsResults)
                self.leTable.reloadData()
            }
        }
    }
    
    func fetchAllRooms(completion: @escaping ([Hit]?) -> ()) {
        guard let url = URL(string: "https://hn.algolia.com/api/v1/search_by_date?query=ios") else {
            completion(nil)
            return
        }
        Alamofire.request(url).responseFeed { response in
                 if let feed = response.result.value {
                    completion(feed.hits)
                 }
                 else{
                    completion(nil)
            }
            }
    }



}
extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try JSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseFeed(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Feed>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

