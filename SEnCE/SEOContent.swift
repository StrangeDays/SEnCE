//
//  SEOContent.swift
//  SEnCE
//
//  Created by Andreas Kostuch on 04.08.14.
//  Copyright (c) 2014 Andreas Kostuch. All rights reserved.
//

import Foundation
import AppKit

public class SEOContent: NSObject, NSCoding, NSCopying {
    // MARK: Initializers
    var content:NSAttributedString
    var keywords:[SEOKeyword]
    
    var htmlString:String {
        var error:NSError? = nil
        
        let regex_style = NSRegularExpression(pattern: "<style.*>[\\s\\S]*?<\\/style>", options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let regex_body = NSRegularExpression(pattern: "<body.*>(.+?|[\\s\\S]*)<\\/body>", options: NSRegularExpressionOptions.CaseInsensitive, error: &error)

        let html = NSString(data: self.content.dataFromRange(NSMakeRange(0, self.content.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], error: &error), encoding: NSUTF8StringEncoding)
            
        var returnHTMLString = ""
        let fullRange = NSMakeRange(0, html.length)
        if let match = regex_style.firstMatchInString(html, options: nil, range: fullRange) {
            returnHTMLString = html.substringWithRange(match.range)
        }
        if let match = regex_body.firstMatchInString(html, options: nil, range: fullRange) {
            returnHTMLString += "\n"
            returnHTMLString += html.substringWithRange(match.range)
        }
        
        return returnHTMLString
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
    
    public init(coder aDecoder: NSCoder) {
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
            let regex = NSRegularExpression(pattern: keyword.keyword, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
            keyword.density = regex.numberOfMatchesInString(self.content.string, options: nil, range: NSMakeRange(0, maxLength))
        }
    }
    
    func removeRow(row:Int) {
        self.keywords.removeAtIndex(row)
    }
    
    func importKeywords(fileName:NSURL, completionHandler: ()->()) {
        var error:NSError?=nil
        
        let fileContents = String.stringWithContentsOfURL(fileName, encoding: NSUTF8StringEncoding, error: &error)
        if !error && fileContents {
            self.keywords = [SEOKeyword]()
            fileContents?.enumerateLines {(line:String, inout stop:Bool) -> () in
                self.keywords.append(SEOKeyword(keyword: line))
            }
            }
            completionHandler()
        }


}