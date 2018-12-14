//
//  ViewController.swift
//  Venue
//
//  Created by anita on 12/12/18.
//  Copyright © 2018 anita. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var coffeeShopIDs = [String]()
    private var coffeeShops = [Venue]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findVenues()
//        tableView.tableFooterView = UIView()
    }
    
    // API Requests
    let clientID = "P402HAXJU35OKOS2ZZLDC3QZ0JQPOZM3IWWQVF2ZR5FMW5MW"
    let clientSecret = "0RD2XLKTPVI11ZTXFH1RKWXOPJQC51IJ0IVCH1YJL4RUDXKF"
    
    let version = "20180323"
    let limit = "15"
    let latLong = "37.7751,-122.3977"
    let query = "coffeeshop"
    
    //  venues/explore endpoint
    func findVenues() {
        let url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=\(clientID)&client_secret=\(clientSecret)&v=\(version)&limit=\(limit)&ll=\(latLong)&query=\(query)")
        guard let exploreUrl = url else { return }
        let task = URLSession.shared.dataTask(with: exploreUrl) { (data, urlResponse, error) in
            guard let data = data, error == nil, urlResponse != nil else {
                print("Didn't get data from the explore endpoint")
                return
            }
            
            do {
                let venues = try JSONDecoder().decode(VenueAPIResponse.self, from: data)
                guard let groups = venues.response.groups else { return }
                let coffeeShops = groups[0].items.map { $0.venue }
                self.coffeeShopIDs = coffeeShops.map { $0.id }
            } catch let error {
                fatalError("error: \(error.localizedDescription)")
//                print(error)
            }
        }
        task.resume()
    }
    
    // venues/id endpoint
    func getDetails(_ venueId: [String]) {
        let dispatchGroup = DispatchGroup()
        for id in venueId {
            dispatchGroup.enter()
            
            let url = URL(string: "https://api.foursquare.com/v2/venues/\(id)?client_id=\(clientID)&client_secret=\(clientSecret)&v=\(version)&limit=\(limit)&ll=\(latLong)&query=\(query)")
            guard let venueUrl = url else { return }
            
            let task = URLSession.shared.dataTask(with: venueUrl) { (data, urlResponse, error) in
                guard let data = data, error == nil, urlResponse != nil else {
                    print("Didn't get data from venue endpoint")
                    return
                }
                
                do {
                    let venues = try JSONDecoder().decode(VenueAPIResponse.self, from: data)
                    guard let venue = venues.response.venue else { return }
                    self.coffeeShops.append(venue)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error {
                    fatalError("error: \(error.localizedDescription)")
                    //                print(error)
                }
                dispatchGroup.leave()
            }
            task.resume()
        }
    }
    
//    func downloadJSON() {
//
//
//        let urlString = "https://api.foursquare.com/v2/venues/explore?client_id=\(clientID)&client_secret=\(clientSecret)&v=\(version)&limit=\(limit)&ll=\(latLong)&query=\(query)"
//        let url = URL(string: urlString)
//
//        guard let downloadURL = url else { return }
//
//        URLSession.shared.dataTask(with: downloadURL) { (data, urlResponse, error) in
//            guard let data = data, error == nil, urlResponse != nil else {
//                print("Something went wrong")
//                return
//            }
//
//            do {
//                let venues = try JSONDecoder().decode(VenueAPIResponse.self, from: data)
//                self.coffeeShops = (venues.response.groups?[0].items.map { $0.venue })!
//                print(self.coffeeShops)
//                //                for venue in venues.response.groups {
//                //                    for item in venue.items {
//                //                        print("Each Venue is: \(item.venue)\n")
//                //                    }
//                //                }
//            } catch let error {
//                print(error)
//            }
//        }.resume()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coffeeShops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell") as? VenueCell else { return UITableViewCell() }
        cell.configureTheCell(coffeeShops[indexPath.row])
        return cell
    }



}

