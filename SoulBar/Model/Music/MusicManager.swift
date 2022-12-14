//
//  MusicManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation
import Alamofire

enum HomeSongType: Int, CaseIterable {
    
    case newSongs = 0
    
    case hotAlbums
    
    case hotPlaylist
    
    case recommend
}

enum HomeSongSection {
    
    static var sections: [String] {
        
        return ["Hot Songs", "Hot Albums", "Hot Playlists", "Recommend For You"]
    }
}

enum SongListType {
    
    static let fromPlaylist = 0
    
    static let fromAlbums = 1
    
    static let fromAlbumsSearch = 2
    
    static var fromArtist = 3

}

enum SearchType {
    
    static let allType = 0
    
    static var artistType = 1
    
    static var songType = 2
    
    static var albumType = 3

}

class MusicManager {
    
    static var sharedInstance = MusicManager()
    
    static let appleMusicBaseURL = "https://api.music.apple.com"
    
    static let appleMusicChartsBaseURL = "https://api.music.apple.com/v1/catalog/tw/charts?"
    
    static let appleMusicSearchBaseURL = "https://api.music.apple.com/v1/catalog/tw/search?"
    
    static let appleMusicSongBaseURL = "https://api.music.apple.com/v1/catalog/tw/songs/"
    
    static let appleMusicPlaylistBaseURL = "https://api.music.apple.com/v1/catalog/tw/playlists/"
    
    static let appleMusicAlbumBaseURL = "https://api.music.apple.com/v1/catalog/tw/albums/"
    
    static let appleMusicArtistBaseURL = "https://api.music.apple.com/v1/catalog/tw/artists/"
    
    func fetchDeveloperToken() -> String? {
        
        let developerAuthenticationToken: String? =
        
        "eyJhbGciOiJFUzI1NiIsImtpZCI6IjI1UTkzTEpOOFYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiIzSEJEOTQyUDZOIiwiZXhwIjoxNjgxOTE1MDIyLCJpYXQiOjE2NjYzNjMwMjJ9.ky-9LnvgMsFcrHllwC9RUevlbPT3ZgpqOJvDpZUrKMSeXylr8m9l_gB9E1CSjzwcz3JNlyXCQK2G3qIt299_YQ"
        
        return developerAuthenticationToken
    }
    
    func searchArtists(term: String, limit: Int, completion: @escaping ([ArtistsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let songsURL = MusicManager.appleMusicSearchBaseURL

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        let param = [

            "types": "artists",

            "term": term,

            "limit": limit

        ] as [String: Any]

        AF.request(songsURL, method: .get, parameters: param, headers: headers).responseDecodable(of: ArtistsSearchResponseObject.self) { response in
            if let data = response.value?.results?.artists?.data {
                
                completion(data)
                
            }
        }
    }
    
    func fetchArtist(with artistID: String, completion: @escaping ([ArtistsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let artistURL = MusicManager.appleMusicArtistBaseURL + artistID

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        AF.request(artistURL, method: .get, headers: headers).responseDecodable(of: ArtistsSearch.self) { response in
            if let data = response.value?.data {

                completion(data)

            }
        }
    }
    
    func fetchArtistsAlbums(with artistID: String, completion: @escaping ([ArtistsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let artistURL = MusicManager.appleMusicArtistBaseURL + artistID

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        AF.request(artistURL, method: .get, headers: headers).responseDecodable(of: ArtistsSearch.self) { response in
            if let data = response.value?.data {

                completion(data)

            }
        }
    }
    
    func searchSongs(term: String, limit: Int, completion: @escaping ([SongsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let songsURL = MusicManager.appleMusicSearchBaseURL

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        let param = [

            "types": "songs",

            "term": term,

            "limit": limit

        ] as [String: Any]

        AF.request(songsURL, method: .get, parameters: param, headers: headers).responseDecodable(of: SongsSearchResponseObject.self) { response in
            if let data = response.value?.results?.songs?.data {

                completion(data)

            }
        }
    }
    
    func searchAlbums(term: String, limit: Int, completion: @escaping ([AlbumsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let songsURL = MusicManager.appleMusicSearchBaseURL

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        let param = [

            "types": "albums",

            "term": term,

            "limit": limit

        ] as [String: Any]

        AF.request(songsURL, method: .get, parameters: param, headers: headers).responseDecodable(of: AlbumsSearchResponseObject.self) { response in
            if let data = response.value?.results?.albums?.data {

                completion(data)

            }
        }
    }
    
    func searchPlaylists(term: String, limit: Int, completion: @escaping ([PlaylistsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let songsURL = MusicManager.appleMusicSearchBaseURL

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        let param = [

            "types": "songs",

            "term": term,

            "limit": limit

        ] as [String: Any]

        AF.request(songsURL, method: .get, parameters: param, headers: headers).responseDecodable(of: PlaylistsSearchResponseObject.self) { response in
            if let data = response.value?.results?.playlists?.data {

                completion(data)

            }
        }
    }

    func fetchSong(with songID: String, completion: @escaping ([SongsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let songURL = MusicManager.appleMusicSongBaseURL + songID

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        AF.request(songURL, method: .get, headers: headers).responseDecodable(of: SongsSearch.self) { response in
            if let data = response.value?.data {

                completion(data)

            }
        }
    }
    
    func fetchSongsCharts(completion: @escaping ([SongsChartsInfo]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let chartURL = MusicManager.appleMusicChartsBaseURL
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        let param = [

            "types": "songs"
            
        ]

        AF.request(chartURL, method: .get, parameters: param, headers: headers).responseDecodable(of: SongsChartsResponseObject.self) { response in
            if let data = response.value?.results?.songs?[0].data {

                completion(data)

            }
        }
    }
    
    func fetchSongsCharts(inNext next: String, completion: @escaping ([SongsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let nextURL = MusicManager.appleMusicBaseURL + next
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        AF.request(nextURL, method: .get, headers: headers).responseDecodable(of: SongsChartsResponseObject.self) { response in
            if let data = response.value?.results?.songs {

                completion(data)

            }
        }
    }
    
    func fetchSongsChartsNext(completion: @escaping ([SongsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let nextURL = MusicManager.appleMusicChartsBaseURL
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        let param = [

            "types": "songs"
            
        ]
        
        AF.request(nextURL, method: .get, parameters: param, headers: headers).responseDecodable(of: SongsChartsResponseObject.self) { response in
            if let data = response.value?.results?.songs {

                completion(data)

            }
        }
    }
    
    func fetchAlbumsCharts(with id: String, completion: @escaping ([SongsSearchInfo]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let albumsURL = "https://api.music.apple.com/v1/catalog/tw/albums/\(id)"
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]

        AF.request(albumsURL, method: .get, headers: headers).responseDecodable(of: SongsSearch.self) { response in
            if let data = response.value?.data {

                completion(data)

            }
        }
    }
    
    func fetchAlbumsCharts(completion: @escaping ([AlbumsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let chartURL = MusicManager.appleMusicChartsBaseURL
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        let param = [

            "types": "albums"
            
        ]
        
        AF.request(chartURL, method: .get, parameters: param, headers: headers).responseDecodable(of: AlbumsChartsResponseObject.self) { response in
            if let data = response.value?.results?.albums {
                
                completion(data)
            }
        }
    }
    
    func fetchAlbumsCharts(inNext next: String, completion: @escaping ([AlbumsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let nextURL = MusicManager.appleMusicBaseURL + next
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        AF.request(nextURL, method: .get, headers: headers).responseDecodable(of: AlbumsChartsResponseObject.self) { response in
            if let data = response.value?.results?.albums {

                completion(data)

            }
        }
    }

    func fetchPlaylistsCharts(completion: @escaping ([PlaylistsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let chartURL = MusicManager.appleMusicChartsBaseURL
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        let param = [

            "types": "playlists"
            
        ]

        AF.request(chartURL, method: .get, parameters: param, headers: headers).responseDecodable(of: PlaylistsChartsResponseObject.self) { response in
            if let data = response.value?.results?.playlists {

                completion(data)

            }
        }
    }
    
    func fetchPlaylistsCharts(inNext next: String, completion: @escaping ([PlaylistsCharts]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let nextURL = MusicManager.appleMusicBaseURL + next
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]
        
        AF.request(nextURL, method: .get, headers: headers).responseDecodable(of: PlaylistsChartsResponseObject.self) { response in
            if let data = response.value?.results?.playlists {

                completion(data)

            }
        }
    }
    
    func fetchPlaylistsCharts(with id: String, completion: @escaping ([SongsSearchInfo]) -> Void) {
        
        var headers = HTTPHeaders()
        
        let albumsURL = "https://api.music.apple.com/v1/catalog/tw/playlists/\(id)"
        
        guard let developerToken = fetchDeveloperToken() else {
            
            fatalError("Cannot fetch developer token")
            
        }
        
        headers = [
            
            .authorization(bearerToken: developerToken)
            
        ]

        AF.request(albumsURL, method: .get, headers: headers).responseDecodable(of: SongsSearch.self) { response in
            if let data = response.value?.data {
                
                completion(data)
            }
        }
    }
    
    func fetchAlbumsTracks(with albumID: String, completion: @escaping ([SongsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let albumID = MusicManager.appleMusicAlbumBaseURL + albumID

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        AF.request(albumID, method: .get, headers: headers).responseDecodable(of: AlbumsSearch.self) { response in
            if let data = response.value?.data?[0].relationships?.tracks.data {

                completion(data)

            }
        }
    }
    
    func fetchPlaylistsTracks(with playlistID: String, completion: @escaping ([SongsSearchInfo]) -> Void) {

        var headers = HTTPHeaders()

        let playlistURL = MusicManager.appleMusicPlaylistBaseURL + playlistID

        guard let developerToken = fetchDeveloperToken() else {

            fatalError("Cannot fetch developer token")

        }

        headers = [

            .authorization(bearerToken: developerToken)

        ]

        AF.request(playlistURL, method: .get, headers: headers).responseDecodable(of: PlaylistsSearch.self) { response in
            if let data = response.value?.data?[0].relationships.tracks.data {

                completion(data)

            }
        }
    }

    func fetchPicture(url: String, width: String, height: String) -> String {
        
        var pictureURL: String = ""
        
        if let widthRange = url.range(of: "{w}") {
            
            pictureURL = url.replacingCharacters(in: widthRange, with: width)

        }
        
        if let heightRange = pictureURL.range(of: "{h}") {
            
            pictureURL = pictureURL.replacingCharacters(in: heightRange, with: height)
            
        }
        
        return pictureURL
    }
    
    func stopAllSessions() {
        
        AF.session.getTasksWithCompletionHandler { _, uploadData, downloadData in
            
            uploadData.forEach { $0.cancel() }
            
            downloadData.forEach { $0.cancel() }
        }
    }
}
