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
                        println(error)
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
                        println(error)
                    } else {
                        venues = result!
                    }
                }
                expect(venues).toEventuallyNot(beEmpty(), timeout: 60)
            }
            
            it("Can persist on realm") {
                let testRealm = Realm(path: realmPathForTesting)
                testRealm.write() {
                    for category in venueCategories {
                        let fCategory:FCategory = testRealm.create(FCategory.self, value: category, update: true)
                    }
                    
                    for venue in venues {
                        let fVenue:FVenue = testRealm.create(FVenue.self, value: venue, update: true)
                    }
                }
                
                let rvenues = testRealm.objects(FVenue)
                
                expect(rvenues.count == venues.count)
            }
            
            it("Can request and perist Venue Details") {
                let testRealm = Realm(path: realmPathForTesting)
                
                var rvenues = testRealm.objects(FVenue)
                for next in rvenues {
                    let venueID = next.id
                    FoursquareClient.sharedInstance().getVenueDetail(next.id) { success, result, errorString in
                        if let error = errorString {
                            println(error)
                        } else {
                            let innerRealm = Realm(path: realmPathForTesting)
                            innerRealm.write() {
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
                let testRealm = Realm(path: realmPathForTesting)
                var rvenues = testRealm.objects(FVenue)
                
                var tags = [String]()
                for (index, next) in enumerate(rvenues) {
                    if next.tags.count > 0 {
                        for (tagIndex, nextTag) in enumerate(next.tags) {
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
    fileManager.removeItemAtPath(path, error: nil)
    let lockPath = "\(path).lock"
    fileManager.removeItemAtPath(lockPath, error: nil)
}

private func documentsDirectoryURL() -> NSURL {
    var error: NSError?
    let url = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
    assert(url != nil, "*** Error finding documents directory: \(error)")
    return url!
}
