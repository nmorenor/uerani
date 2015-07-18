//
//  FoursquareConfig.swift
//  grabbed
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class FoursquareConfig:NSObject, NSCoding {
    
    let DateUpdatedKey = "config.date_update_key"
    var dateUpdated:NSDate? = nil
    static let _fileURL:NSURL = documentsDirectoryURL().URLByAppendingPathComponent("FoursquareContext")
    
    public override init() {

    }
    
    public var daysSinceLastUpdate:Int? {
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSinceDate(lastUpdate) / 60*60*24)
        } else {
            return nil
        }
    }
    
    public func updateIfDaysSinceUpdateExceeds(days: Int) {
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        }
        //TODO: Do something clever :)
        
        FoursquareClient.sharedInstance().config.save()
    }
    
    public required init(coder aDecoder: NSCoder) {
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    public func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: FoursquareConfig._fileURL.path!)
    }
    
    class func unarchivedInstance() -> FoursquareConfig? {
        if NSFileManager.defaultManager().fileExistsAtPath(FoursquareConfig._fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(FoursquareConfig._fileURL.path!) as? FoursquareConfig
        } else {
            return nil
        }
    }
}


