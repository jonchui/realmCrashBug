//
//  DataModel.swift
//  Test
//
//  Created by Jordan Hipwell on 2/27/18.
//  Copyright © 2018 Jordan Hipwell. All rights reserved.
//

import Foundation
import RealmSwift

final class DataModel: NSObject {
    static let shared = DataModel()
    
    var realm: Realm? {
        do {
            return try Realm()
        } catch {
            print(error)
            return nil
        }
    }
    
    override init() {
        super.init()
        
        #if DEBUG
            print("\nRealm file:")
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "") //path to local db
            print("\n")
        #endif
    }
    
    func delete(object: Object) {
        guard let realm = realm else { return }
        try? realm.write {
            realm.delete(object)
        }
    }
    
    func addSampleData() {
        guard let realm = realm else { return }
        
        try? realm.write {
            let artist = Artist()
            artist.name = "Artist 1"
            
            for i in 0..<2 {
                let album = Album()
                album.name = "Album \(i+1)"
                
                artist.albums.append(album)
                
                for j in 0..<3 {
                    let song = Song()
                    song.name = "Song \(j+1)"
                    
                    album.songs.append(song)
                }
            }
            
            realm.add(artist)
        }
    }
    
    func deleteAlbum(_ album: Album) {
        album.cascadeDelete()
    }
    
    func deleteAll() {
        realm?.objects(Artist.self).forEach { $0.cascadeDelete() }
    }
}

final class Artist: Object {
    @objc dynamic var name = ""
    let albums = List<Album>()
    
    func cascadeDelete() {
        albums.forEach { $0.cascadeDelete() }
        //the artist is deleted after all albums are deleted
    }
}

final class Album: Object {
    @objc dynamic var name = ""
    let artists = LinkingObjects(fromType: Artist.self, property: "albums")
    let songs = List<Song>()
    
    func cascadeDelete() {
        let artist = artists.first
        
        songs.forEach { $0.cascadeDelete() }
        //the album is deleted after all songs are deleted
        
        if let artist = artist {
            if artist.albums.isEmpty {
                DataModel.shared.delete(object: artist)
            }
        }
    }
}

final class Song: Object {
    @objc dynamic var name = ""
    let albums = LinkingObjects(fromType: Album.self, property: "songs")
    
    func cascadeDelete() {
        let album = albums.first
        
        DataModel.shared.delete(object: self)
        print("DELETED SONG")
        
        if let album = album {
            if album.songs.isEmpty {
                print("WILL DELETE ALBUM")
                DataModel.shared.delete(object: album)
                print("DELETED ALBUM")
            }
        }
    }
    
}
