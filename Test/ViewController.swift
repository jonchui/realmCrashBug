//
//  ViewController.swift
//  Test
//
//  Created by Jordan Hipwell on 2/27/18.
//  Copyright © 2018 Jordan Hipwell. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private var artists = DataModel.shared.realm?.objects(Artist.self)
    private var artistsChangeNotificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observe changes to artists (and all nested properties)
        artistsChangeNotificationToken = artists?.observe { changes in
            print("RELOADING") //set breakpoint here for best chance to reproduce crash
            self.tableView.reloadData()
        }
    }

    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        DataModel.shared.deleteAll()
        DataModel.shared.addSampleData()
    }
    
    @IBAction func didTapDeleteAlbum(_ sender: UIBarButtonItem) {
        guard let album = artists?.last?.albums.last else { return }
        DataModel.shared.deleteAlbum(album)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("number of sections: \(artists?.count ?? 0)")
        return artists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows in section \(section): \(artists![section].albums.count)")
        return artists![section].albums.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let artist = artists![section]
        return artist.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for row at \(indexPath)")
        
        let artist = artists![indexPath.section]
        let album = artist.albums[indexPath.row] //CRASH HERE
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = album.name
        return cell
    }
    
}
