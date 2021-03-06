//
//  VenueDetailViewModel.swift
//  uerani
//
//  Created by nacho on 9/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

public protocol VenueMapImageDelegate : class {
    
    func refreshMapImage()
}

public class VenueDetailViewModel<T:Venue> : VenueDetailAccessoryDelegate {
    
    var id:String!
    var name:String!
    var imageSize:CGSize!
    var email:String?
    var phone:String?
    var address:String?
    var conuntry:String?
    var state:String?
    var city:String?
    var postalCode:String?
    var tags:[String]?
    var rating:Float!
    var photoIdentifier:String?
    var price:String?
    var isOpen:Bool?
    var status:String?
    var timeFrames:String?
    var venueDescription:String?
    var uberPriceViewModel:UberPriceViewModel?
    
    init(venue:T, imageSize:CGSize, updateCoreData:Bool, delegate:VenueDetailsDelegate?) {
        self.imageSize = imageSize
        self.id = venue.id
        self.loadData(venue)
        var updated = false
        if let delegate = delegate where !venue.completeVenue {
            _ = VenueDetailOperation(venueId: venue.id, imageSize: imageSize, updateCoreData:updateCoreData, delegate: delegate)
            updated = true
        } else if let bestPhoto = venue.c_bestPhoto {
            if let identifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: bestPhoto) {
                let image = ImageCache.sharedInstance().imageWithIdentifier(identifier)
                if image == nil {
                    _ = VenueDetailOperation(venueId: venue.id, imageSize: imageSize, updateCoreData:updateCoreData, delegate: delegate)
                    updated = true
                }
            } else {
                _ = VenueDetailOperation(venueId: venue.id, imageSize: imageSize, updateCoreData:updateCoreData, delegate: delegate)
                updated = true
            }
        }
        
        if !updated && daysSinceLastUpdate(venue) > 7 {
            _ = VenueDetailOperation(venueId: venue.id, imageSize: imageSize, updateCoreData:updateCoreData, delegate: delegate)
        }
    }
    
    private func daysSinceLastUpdate(venue:T) -> Int? {
        let timeInterval = NSDate().timeIntervalSinceDate(venue.lastUpdate)
        return Int(timeInterval / (60*60*24))
    }

    
    static func getBestPhotoIdentifier(venueId:String, imageSize:CGSize, bestPhoto:Photo) -> String? {
        let size = "\(imageSize.width.getIntValue())x\(((imageSize.height/2) * 1.15).getIntValue())"
        let url = NSURL(string: "\(bestPhoto.iprefix)\(size)\(bestPhoto.isuffix)")!
        if let identifier = getImageIdentifier(url) {
            return "venue_\(venueId)_\(identifier)"
        }
        return nil
    }
    
    func loadData(venue:T) {
        self.name = venue.name
        self.rating = venue.rating
        self.loadContactData(venue)
        self.loadLocationData(venue)
        self.loadTagData(venue)
        self.loadPriceData(venue)
        
        if !venue.venueDescription.isEmpty {
            self.venueDescription = venue.venueDescription
        }
        
        if let hours = venue.c_hours {
            if !hours.status.isEmpty {
                self.status = hours.status
            }
            let timeFrames = hours.c_timeFrames
            var times = [String]()
            for next in timeFrames {
                var frame = "\(next.days)"
                let openFrames = next.c_open
                
                var frames:[String] = [String]()
                for nextFrame in openFrames {
                    frames.append(nextFrame.renderedTime)
                }
                if !frames.isEmpty {
                    frame += ": "
                    for i in 0..<frames.count {
                        if i > 0 {
                            frame += " - "
                        }
                        frame += "\(frames[i])"
                    }
                }
                
                times.append(frame)
            }
            if !times.isEmpty {
                var result = ""
                for i in 0..<times.count {
                    result += "\(times[i])"
                    if i < (times.count - 1) {
                        result += "\n"
                    }
                }
                
                if !result.isEmpty {
                    self.timeFrames = "Hours:\n\(result)"
                }
            }
            
            self.isOpen = hours.isOpen
        }
        
        if let bestPhoto = venue.c_bestPhoto {
            self.photoIdentifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: bestPhoto)
        }
    }
    
    private func loadPriceData(venue:T) {
        if let price = venue.c_price {
            if !price.message.isEmpty {
                self.price = price.message
            }
        }
    }
    
    private func loadTagData(venue:T) {
        var tags = [String]()
        for tag in venue.c_tags {
            tags.append(tag.tagvalue)
        }
        self.tags = tags
    }
    
    private func loadLocationData(venue:T) {
        if let location = venue.c_location {
            if !location.address.isEmpty {
                self.address = location.address
            }
            if !location.city.isEmpty {
                self.city = location.city
            }
            if !location.country.isEmpty {
                self.conuntry = location.country
            }
            if !location.state.isEmpty {
                self.state = location.state
            }
            if !location.postalCode.isEmpty {
                self.postalCode = location.postalCode
            }
        }
    }
    
    private func loadContactData(venue:T) {
        if let contact = venue.c_contact {
            if !contact.email.isEmpty {
                self.email = contact.email
            }
            if !contact.formattedPhone.isEmpty {
                self.phone = contact.formattedPhone
            } else if !contact.phone.isEmpty {
                self.phone = contact.phone
            }
        }
    }
    
    func setupImageView(view:VenueImageView, imageMapDelegate:VenueMapImageDelegate, venue:T) {
        if let imageIdentifier = self.photoIdentifier, let image = ImageCache.sharedInstance().imageWithIdentifier(imageIdentifier) {
            view.image = image
        }
        if let image = ImageCache.sharedInstance().imageWithIdentifier("venue_map_\(self.id)") {
            view.mapImage = image
        } else {
            let annotation = FoursquareLocationMapAnnotation(venue: venue)
            let snapshotter = self.getSnapshotter(annotation)
            snapshotter.startWithQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { snapshot, error in
                self.generateVenueMapImage(annotation, imageMapDelegate: imageMapDelegate, snapshot: snapshot!, error: error)
            }
        }
    }
    
    func setupRatingView(view:VenueRatingView) {
        view.rating = String(format: "%.1f", self.rating)
        if view.rating == "0.0" {
            view.hidden = true
        } else {
            view.hidden = false
        }
    }
    
    func setupDetailsView(view:VenueDetailsView) {
        
        var locationView:VenueDetailView!
        if let view = view.locationView {
            locationView = view
        } else {
            locationView = VenueDetailView()
            view.locationView = locationView
        }
        if canRequestUberFare() && locationView.accessoryImage == nil {
            locationView.accessoryImage = UIImage(named: "uber")!
            locationView.accessoryDelegate = self
        }
        
        locationView.text = getFormattedLocation()
        locationView.image = UIImage(named: "map_pin_black_64")!.resizeImageWithScale(0.25)
        
        if let uberPriceViewModel = self.uberPriceViewModel, let priceValue = uberPriceViewModel.value {
            var uberView:VenueDetailView!
            if let view = view.uberView {
                uberView = view
            } else {
                uberView = VenueDetailView()
                view.uberView = uberView
            }
            uberView.text = priceValue
        }
        
        if let phone = self.phone {
            var phoneView:VenueDetailView!
            if let view = view.phoneView {
                phoneView = view
            } else {
                phoneView = VenueDetailView()
                view.phoneView = phoneView
            }
            phoneView.text = phone
            phoneView.image = UIImage(named: "phone")!.resizeImageWithScale(0.25)
        }
        
        if let mail = self.email {
            var mailView:VenueDetailView!
            if let view = view.mailView {
                mailView = view
            } else {
                mailView = VenueDetailView()
                view.mailView = mailView
            }
            mailView.text = mail
            mailView.image = UIImage(named: "message")?.resizeImageWithScale(0.25)
        }
        
        if let hours = self.timeFrames {
            var hoursView:VenueDetailView!
            if let view = view.hoursView {
                hoursView = view
            } else {
                hoursView = VenueDetailView()
                view.hoursView = hoursView
            }
            hoursView.text = hours
        }
        
        if let venueDescription = self.venueDescription {
            var descriptionView:VenueDetailView!
            if let view = view.descriptionView {
                descriptionView = view
            } else {
                descriptionView = VenueDetailView()
                view.descriptionView = descriptionView
            }
            descriptionView.text = venueDescription
        }
        
        view.layoutSubviews()
    }
    
    func handleAccessoryTouch() {
        self.uberPriceViewModel?.requestFare()
    }
    
    func canRequestUberFare() -> Bool {
        if let _ = UberClient.sharedInstance().accessToken, let _ = LocationRequestManager.sharedInstance().location {
            return true
        }
        return false
    }
    
    func getFormattedLocation() -> String {
        var result = "\(self.name)\n"
        if let address = self.address {
            result += "\(address)\n"
        }
        if let postalCode = self.postalCode, let city = self.city, let state = self.state {
            result += "\(postalCode), \(city), \(state)"
        } else if let city = self.city, let state = self.state  {
            result += "\(city), \(state)"
        } else if let city = self.city {
            result += "\(city)"
        } else if let state = self.state {
            result += "\(state)"
        }
        
        return result
    }
    
    private func getSnapshotter(annotation:FoursquareLocationMapAnnotation) -> MKMapSnapshotter {
        let options = MKMapSnapshotOptions()
        
        let size = CGSizeMake(imageSize.width * 0.65, imageSize.height * 0.75)
        
        options.size = size
        options.scale = UIScreen.mainScreen().scale
        options.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 150.0, 150.0)
        
        return MKMapSnapshotter(options: options)
    }
    
    private func generateVenueMapImage(annotation:FoursquareLocationMapAnnotation, imageMapDelegate:VenueMapImageDelegate, snapshot:MKMapSnapshot, error:NSError?) {
        if let _ = error {
            if DEBUG {
                print("Error taking map snapshot image", terminator: "")
            }
        } else {
            //map image
            let image = snapshot.image
            
            //configura annotation for map image
            let annotationView = CategoryPinAnnotationView(annotation: annotation, reuseIdentifier: "foursquarePin")
            annotationView.configure(annotation, scaledImageIdentifier: annotation.categoryImageName12!, size: CGSizeMake(8, 8))
            let scale = UIScreen.mainScreen().scale
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(annotationView.image!.size.width + 5, annotationView.image!.size.height + 10), false, scale)
            let context:CGContextRef = UIGraphicsGetCurrentContext()!
            //draw annotation
            annotationView.drawInContext(context)
            let annotationImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
            image.drawAtPoint(CGPointMake(0, 0))
            
            var point = snapshot.pointForCoordinate(annotation.coordinate)
            let pinCenterOffset = annotationView.centerOffset;
            point.x -= annotationImage.size.width / 2;
            point.y -= annotationImage.size.height / 2;
            //extract the triangle height
            point.y -= annotationView.image!.size.height * 0.4
            point.x += pinCenterOffset.x;
            
            point.y += pinCenterOffset.y;
            
            annotationImage.drawAtPoint(point)
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            ImageCache.sharedInstance().storeImage(finalImage, withIdentifier: "venue_map_\(annotation.venueId)")
            
            UIGraphicsEndImageContext()
            
            imageMapDelegate.refreshMapImage()
        }
    }
}
