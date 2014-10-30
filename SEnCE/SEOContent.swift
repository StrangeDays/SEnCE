//
//  SEOContent.swift
//  SEnCE
//
//  Created by Andreas Kostuch on 04.08.14.
//  Copyright (c) 2014 Andreas Kostuch. All rights reserved.
//

import Foundation
import AppKit

func regex_content(regex:String, content:String) -> String {
    var error:NSError?=nil
    let fullRange = NSMakeRange(0, countElements(content))
    let r = NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)!
    var m:NSTextCheckingResult? = r.firstMatchInString(content, options: nil, range: fullRange)
    if let match = m {
        return (content as NSString).substringWithRange(match.range)
    }
    return ""
}

func regexps_content<T>(content:T, regexps:String...) -> String {
    var contentAsString=""
    var s = ""
    switch content {
    case is String:
        contentAsString = content as String
    case is NSAttributedString:
        var error:NSError? = nil
        contentAsString = NSString(data: (content as NSAttributedString).dataFromRange(NSMakeRange(0, (content as NSAttributedString).length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], error: &error)!, encoding: NSUTF8StringEncoding)!
        if !(error==nil) {
            return ""
        }
    default:
        return ""
    }
    
    for regex in regexps {
        s += "\n\n\(regex_content(regex, contentAsString))"
    }
    return s
}

public class SEOContent: NSObject, NSCoding, NSCopying {
    // MARK: Initializers
    var content:NSAttributedString
    var keywords:[SEOKeyword] = []
    var htmlString:String {
    get {
        return regexps_content(self.content, "<style.*>[\\s\\S]*?<\\/style>", "<body.*>(.+?|[\\s\\S]*)<\\/body>")
    }
    set {
        regexps_content(self.content, "<style.*>[\\s\\S]*?<\\/style>", "<body.*>(.+?|[\\s\\S]*)<\\/body>")
    }
    }
    
    private struct SerializationKey {
        static let keywords = "keywords"
        static let content = "content"
    }
    
    public init(content: NSAttributedString, keywords: [SEOKeyword]) {
        self.content = content
        self.keywords = keywords.map { $0.copy() as SEOKeyword }
    }
    
    public convenience init(content:NSAttributedString) {
        self.init(content: content, keywords: [])
    }
    
    // MARK: NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        keywords = aDecoder.decodeObjectForKey(SerializationKey.keywords) as [SEOKeyword]
        content = aDecoder.decodeObjectForKey(SerializationKey.content) as NSAttributedString
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(keywords, forKey: SerializationKey.keywords)
        aCoder.encodeObject(content, forKey: SerializationKey.content)
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        return SEOContent(content: content, keywords: keywords)
    }
    
    func countKeywords() {
        var error:NSError? = nil
        
        let maxLength = self.content.length
        for keyword in keywords {
            let regex = NSRegularExpression(pattern: keyword.keyword, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)!
            keyword.density = regex.numberOfMatchesInString(self.content.string, options: nil, range: NSMakeRange(0, maxLength))
        }
    }
    
    func removeRow(row:Int) {
        self.keywords.removeAtIndex(row)
    }
    
    func importKeywords(fileName:NSURL, completionHandler: ()->()) {
        var error:NSError?=nil
        let fileContents = String(contentsOfURL: fileName, encoding: NSUTF8StringEncoding, error: &error)
        if let code = error?.code {
			println("Error opening file")
            return
        }
		self.keywords.removeAll(keepCapacity: false)
        fileContents?.enumerateLines {(line:String, inout stop:Bool) -> () in
            self.keywords.append(SEOKeyword(keyword: line))
        }
        completionHandler()
    }

}