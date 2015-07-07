//
//  main.swift
//  Spotify Migrate -- Get your playlists out of Spotify
//
//  Created by Toby Padilla on 7/6/15.
//  Copyright © 2015 Toby Padilla. All rights reserved.
//

import Foundation

typealias TrackArtist = String
typealias TrackTitle = String

enum PlaylistItem {
    case Artist(String)
    case PlaylistTitle(String)
    case Track(TrackArtist,TrackTitle)
}

typealias Playlist = [PlaylistItem]
typealias Token = String
typealias TokenLine = [Token]
typealias TokenFile = [TokenLine]

let tokenDelimiter = "–" as Character

func tokenizeString(string: String) -> Token {
    return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}

func tokenizeCharacterView(characterView: String.CharacterView) -> Token {
    return tokenizeString(String(characterView))
}

func tokenizeLine(line: String.CharacterView) -> TokenLine {
    return split(line) {return $0 == tokenDelimiter}.map(tokenizeCharacterView)
}

func tokenizeData(data: NSData) -> TokenFile {
    let input = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    return split(input.characters) {return $0 == "\n"}.map(tokenizeLine)
}

func tokenLineToPlaylistItem(tokens: TokenLine) -> PlaylistItem? {
    switch(tokens.count) {
    case 0:
        return nil
    case 1:
        return .PlaylistTitle(tokens[0])
    case 2:
        return .Track(tokens[1], tokens[0]) // flip artist and track since spotify exports it backwards
    default:
        return nil
    }
}

func reducePlaylistItems(var res: [Playlist], item: PlaylistItem) -> [Playlist] {
    switch(item) {
    case .PlaylistTitle(_):
        res.insert([item], atIndex: 0)
        return res
    case .Track(_,_):
        var lastPlaylist = res[0]
        lastPlaylist.append(item)
        res[0] = lastPlaylist
        return res
    default:
        return res
    }
}

func playlistItemsToPlaylists(items: [PlaylistItem]) -> [Playlist] {
    return items.reduce([Playlist](), combine: reducePlaylistItems).reverse()
}

func decodeDataToPlaylists(data: NSData) -> [PlaylistItem] {
    let tokenFile = tokenizeData(data)
    let playlistItems = tokenFile.map(tokenLineToPlaylistItem).filter({$0 != nil}).map({$0!})
    return playlistItems
}

func renderPlaylistItem(item: PlaylistItem, formatter: PlaylistItem -> String) -> String {
    return formatter(item)
}

func renderPlaylist(playlist: Playlist, formatter: PlaylistItem -> String) -> String {
    return "\n".join(playlist.map({renderPlaylistItem($0, formatter: formatter)}))
}

func renderPlaylists(playlists: [Playlist], formatter: PlaylistItem -> String) -> String {
    return "\n\n".join(playlists.map({renderPlaylist($0, formatter: formatter)}))
}

func mdFormat(item: PlaylistItem) -> String {
    switch(item) {
    case .PlaylistTitle(let title):
        return "## \(title)"
    case .Track(let artist, let track):
        return "* \(artist) \(tokenDelimiter) \(track)"
    default:
        return ""
    }
}

let data = NSFileHandle.fileHandleWithStandardInput().availableData
let playlistItems = decodeDataToPlaylists(data)
let playlists = playlistItemsToPlaylists(playlistItems)
print(renderPlaylists(playlists, formatter: mdFormat))
