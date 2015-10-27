import Quick
import Nimble
import uerani
import MapKit
import RealmSwift

class FoursquareClientTests: QuickSpec {
    
    override func spec() {
        var realmPathForTesting = ""
        
        beforeSuite() {
            realmPathForTesting = documentsDirectoryURL().URLByAppendingPathComponent("testingRealm").path!
            deleteRealmFilesAtPath(realmPathForTesting)
        }
        
        describe("Foursquare venue search") {
            var client:FoursquareClient!
            var venues:[[String:AnyObject]] = [[String:AnyObject]]()
            var venueCategories:[[String:AnyObject]] = [[String:AnyObject]]()
            beforeEach {
                client = FoursquareClient.sharedInstance()
            }
            
            it("Can find venue categories") {
                client.searchCategories() { success, result, errorString in
                    if let error = errorString {
                        print(error)
                    } else {
                        venueCategories = result!
                    }
                }
                expect(venueCategories).toEventuallyNot(beEmpty(), timeout: 60)
            }
            
            it("Can find venues") {
                
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7, longitude: -74)
                client.searchVenuesForLocation(location) { success, result, errorString in
                    if let error = errorString {
                        print(error)
                    } else {
                        venues = result!
                    }
                }
                expect(venues).toEventuallyNot(beEmpty(), timeout: 60)
            }
            
            it("Can persist on realm") {
                let testRealm = try! Realm(path: realmPathForTesting)
                try! testRealm.write() {
                    for category in venueCategories {
                        let fCategory:FCategory = testRealm.create(FCategory.self, value: category, update: true)
                        print(fCategory)
                    }
                    
                    for venue in venues {
                        let fVenue:FVenue = testRealm.create(FVenue.self, value: venue, update: true)
                        print(fVenue)
                    }
                }
                
                let rvenues = testRealm.objects(FVenue)
                
                expect(rvenues.count == venues.count)
            }
            
            it("Can request and perist Venue Details") {
                let testRealm = try! Realm(path: realmPathForTesting)
                
                let rvenues = testRealm.objects(FVenue)
                for next in rvenues {
                    let venueID = next.id
                    print(venueID)
                    FoursquareClient.sharedInstance().getVenueDetail(next.id) { success, result, errorString in
                        if let error = errorString {
                            print(error)
                        } else {
                            let innerRealm = try! Realm(path: realmPathForTesting)
                            try! innerRealm.write() {
                                if let result = result  {                               
                                    let fVenue:FVenue = innerRealm.create(FVenue.self, value: result, update: true)
                                    fVenue.completeVenue = true
                                }
                            }
                        }
                    }
                }
                
                expect(testRealm.objects(FVenue).filter(NSPredicate(format: "completeVenue == false"))).toEventually(beEmpty(), timeout: 60)
            }
            
            it ("Can find tags") {
                let testRealm = try! Realm(path: realmPathForTesting)
                let rvenues = testRealm.objects(FVenue)
                
                var tags = [String]()
                for next in rvenues {
                    if next.tags.count > 0 {
                        for nextTag in next.tags {
                            tags.append(nextTag.tagvalue)
                        }
                    }
                }
                
                expect(tags).notTo(beEmpty())
            }
        }
        
        afterSuite() {
            deleteRealmFilesAtPath(realmPathForTesting)
        }
    }
}

private func deleteRealmFilesAtPath(path: String) {
    let fileManager = NSFileManager.defaultManager()
    do {
        try fileManager.removeItemAtPath(path)
    } catch _ {
    }
    let lockPath = "\(path).lock"
    do {
        try fileManager.removeItemAtPath(lockPath)
    } catch _ {
    }
}

private func documentsDirectoryURL() -> NSURL {
    var error: NSError?
    let url: NSURL?
    do {
        url = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    } catch let error1 as NSError {
        error = error1
        url = nil
    }
    assert(url != nil, "*** Error finding documents directory: \(error)")
    return url!
}
