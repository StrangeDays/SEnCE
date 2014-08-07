//
//  SEOKeywords.swift
//  SEnCE
//
//  Created by Andreas Kostuch on 04.08.14.
//  Copyright (c) 2014 Andreas Kostuch. All rights reserved.
//

import Foundation
import Cocoa

public class SEOKeyword: NSObject, NSCopying, NSCoding {
    var keyword:String
    var density:Int
    var status:KeywordStatus {
    switch density {
    case 0:
        return .Default
    case 1:
        return .LightGreen
    case 2:
        return .Green
    default:
        return .Red
        }
    }
    
    private struct SerializationKey {
        static let keyword = "keyword"
        static let density = "density"
    }
    
    enum KeywordStatus {
        case Green, LightGreen, Red, Default
        var statusColor:NSColor {
        switch self {
        case .Green:
            return NSColor.greenColor()
        case .LightGreen:
            return NSColor.greenColor()
        case .Red:
            return NSColor.redColor()
        default:
            return NSColor.whiteColor()
        }
        }
    }
    
    init(keyword:String, density:Int) {
        self.keyword = keyword
        self.density = density
    }
    
    convenience init(keyword:String) {
        self.init(keyword: keyword, density: 0)
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        return SEOKeyword(keyword: keyword, density: density)
    }
    
    // MARK: NSCoding
    
    public init(coder aDecoder: NSCoder) {
        keyword = aDecoder.decodeObjectForKey(SerializationKey.keyword) as String
        density = aDecoder.decodeIntegerForKey(SerializationKey.density)
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(keyword, forKey: SerializationKey.keyword)
        encoder.encodeInteger(density, forKey: SerializationKey.density)
    }
    
    override public func isEqual(object: AnyObject!) -> Bool {
        if let a = object as? SEOKeyword {
            return keyword == a.keyword
        }
        return false
    }
}