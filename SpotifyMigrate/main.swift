//
//  main.swift
//  SpotifyMigrate
//
//  Created by Toby Padilla on 7/6/15.
//  Copyright © 2015 Toby Padilla. All rights reserved.
//

import Foundation

enum PlaylistItem {
    case Title(String)
    case Track(String,String)
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
        return .Title(tokens[0])
    case 2:
        return .Track(tokens[1], tokens[0]) // flip artist and track since spotify exports it backwards
    default:
        return nil
    }
}

func decodeDataToPlaylists(data: NSData) -> [PlaylistItem] {
    let tokenFile = tokenizeData(data)
    let playlistItems = tokenFile.map(tokenLineToPlaylistItem).filter({$0 != nil}).map({$0!})
    return playlistItems
}

func renderPlaylistItem(item: PlaylistItem, formatter: PlaylistItem -> String) -> String {
    return formatter(item)
}

func renderPlaylistItems(items: [PlaylistItem], formatter: PlaylistItem -> String) -> String {
    return "\n".join(items.map({renderPlaylistItem($0, formatter: formatter)}))
}

func mdFormat(item: PlaylistItem) -> String {
    switch(item) {
    case .Title(let title):
        return "\n## \(title)"
    case .Track(let artist, let track):
        return "* \(artist) - \(track)"
    }
}

let data = NSFileHandle.fileHandleWithStandardInput().availableData
let playlistItems = decodeDataToPlaylists(data)
print(renderPlaylistItems(playlistItems, formatter: mdFormat))
