//
//  Document.swift
//  SEnCE
//
//  Created by Andreas Kostuch on 04.08.14.
//  Copyright (c) 2014 Andreas Kostuch. All rights reserved.
//

import Cocoa

class KewyordTableRowView:NSTableRowView {
    override func drawBackgroundInRect(dirtyRect: NSRect) {
        super.drawBackgroundInRect(dirtyRect)
        self.backgroundColor = NSColor.greenColor()
    }
}

@objc protocol MyTableViewDelegate {
    func deleteKeyPressed(row:Int)
}

extension NSTableView {
    override public func keyDown(theEvent: NSEvent) {
        if let d = self.delegate() as? MyTableViewDelegate {
            if theEvent.keyCode==51 {
                d.deleteKeyPressed(self.selectedRow)
            }
        }
    }
}

class Document: NSDocument, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate, MyTableViewDelegate, NSTabViewDelegate {
    @IBOutlet var textView:NSTextView!
	@IBOutlet var htmlTextView:NSTextView!
	
    @IBOutlet var tableKeywords:NSTableView!
    @IBOutlet var statusLabel:NSTextField!
	@IBOutlet var arrayController:NSArrayController!
	
    var seoContent:SEOContent! = SEOContent(content: NSAttributedString(), keywords: [])

    
    func deleteKeyPressed(row:Int) {
        self.seoContent.removeRow(row)
        self.tableKeywords.reloadData()
    }
    
    @IBAction func importKeywords(sender:AnyObject) {
        let o = NSOpenPanel()
        o.prompt = "Select"
        o.beginWithCompletionHandler { (result:Int)-> Void in
            if result == NSFileHandlingPanelOKButton {
				self.seoContent.importKeywords(o.URL!, completionHandler: { [weak self]() -> Void in
					self!.seoContent.countKeywords()
					self!.arrayController.content = self?.seoContent.keywords
					self!.tableKeywords.reloadData()
				})

            }
        }
    }
	
	func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [AnyObject]) {
		let sorted = NSArray(array: self.seoContent.keywords).sortedArrayUsingDescriptors(tableView.sortDescriptors)
		self.seoContent.keywords = sorted as [SEOKeyword]
		self.arrayController.content = self.seoContent.keywords
		tableView.reloadData()
	}

    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        self.textView.delegate = self
        
        if (self.seoContent != nil) {
            self.textView.textStorage?.setAttributedString(self.seoContent.content)
            self.tableKeywords.reloadData()
            self.setStatusLabel()
        }
    }		

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }

    override func dataOfType(typeName: String?, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        self.seoContent.content = self.textView.attributedString()
		let d:NSData? = NSKeyedArchiver.archivedDataWithRootObject(self.seoContent)
        if let data =  d {
            return data
        }
        return nil
    }

    func tableView(tableView: NSTableView!, willDisplayCell cell: AnyObject!, forTableColumn tableColumn: NSTableColumn!, row: Int) {
        
        if let c = cell as? NSTextFieldCell {
            c.drawsBackground = true
            c.backgroundColor = self.seoContent.keywords[row].status.statusColor
        }

    }
	
    override func readFromData(data: NSData?, ofType typeName: String?, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        var error:NSError? = nil
        if let c = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? SEOContent {
            self.seoContent = c
            return true
        }
        if (outError != nil) {
            outError.memory = NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not read file.", comment: "Read error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format.", comment: "Read failure reason")
                ])
        }
        return false
    }
    
    func textDidChange(notification: NSNotification!) {
        self.seoContent.content = self.textView.attributedString()
        self.seoContent.htmlString=""
        self.seoContent.countKeywords()
        self.tableKeywords.reloadData()
        self.setStatusLabel()
    }
    
    func wrapHTML(startTag:String) {
        let endTag = startTag.stringByReplacingOccurrencesOfString("<", withString: "</", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        let range = self.textView.selectedRange()
        let start = NSMakeRange(range.location, 0)
        let end = NSMakeRange(range.location+range.length, 0)
        self.textView.insertText(endTag, replacementRange: end)
        self.textView.insertText(startTag, replacementRange: start)
    }
    
    func setStatusLabel() {
        var wCount = NSSpellChecker().countWordsInString(self.textView.string!, language: nil)
        let keyword_sum = self.seoContent.keywords.reduce(0, combine: {$0.0 + $1.density})
        var perc = Double(keyword_sum) / (Double(wCount)*0.01)
        self.statusLabel.stringValue = "Keywords: \(keyword_sum) | Wörter: \(wCount) | Gesamtdichte: \(round(perc)) %"
    }
    
    @IBAction func makeParagraph(sender:AnyObject) {
        wrapHTML("<p>")
    }
    
    @IBAction func makeBold(sender:AnyObject) {
        wrapHTML("<strong>")
    }
    
    @IBAction func removeRow(sender:AnyObject) {
        println("Remove Object")
    }
    
    @IBAction func ShowHTML(sender:AnyObject) {
    
    }
	
	func tabView(tabView: NSTabView, willSelectTabViewItem tabViewItem: NSTabViewItem?) {
		self.htmlTextView.string = self.seoContent.htmlString
	}
	
}

