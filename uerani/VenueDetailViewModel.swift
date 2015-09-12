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

public class VenueDetailViewModel<T:Venue> {
    
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
    
    init(venue:T, imageSize:CGSize, delegate:VenueDetailsDelegate?) {
        self.imageSize = imageSize
        self.id = venue.id
        self.loadData(venue)
        if let delegate = delegate where !venue.completeVenue {
            VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
        } else if let bestPhoto = venue.c_bestPhoto {
            if let identifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: bestPhoto) {
                var image = ImageCache.sharedInstance().imageWithIdentifier(identifier)
                if image == nil {
                    VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
                }
            } else {
                VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
            }
        }
        
        if daysSinceLastUpdate(venue) > 7 {
            VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
        }
    }
    
    private func daysSinceLastUpdate(venue:T) -> Int? {
        var timeInterval = NSDate().timeIntervalSinceDate(venue.lastUpdate)
        return Int(timeInterval / (60*60*24))
    }

    
    static func getBestPhotoIdentifier(venueId:String, imageSize:CGSize, bestPhoto:Photo) -> String? {
        var size = "\(imageSize.width.getIntValue())x\(((imageSize.height/2) * 1.15).getIntValue())"
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
        
        if let hours = venue.c_hours {
            if !hours.status.isEmpty {
                self.status = hours.status
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
            var annotation = FoursquareLocationMapAnnotation(venue: venue)
            var snapshotter = self.getSnapshotter(annotation)
            snapshotter.startWithQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { snapshot, error in
                self.generateVenueMapImage(annotation, imageMapDelegate: imageMapDelegate, snapshot: snapshot, error: error)
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
        if let locationView = view.locationView {
            locationView.text = getFormattedLocation()
            locationView.image = UIImage(named: "map_pin_black_64")!.resizeImageWithScale(0.25)
        } else {
            view.locationView = VenueDetailView()
            view.locationView!.text = getFormattedLocation()
            view.locationView!.image = UIImage(named: "map_pin_black_64")!.resizeImageWithScale(0.25)
        }
        view.layoutSubviews()
    }
    
    func getFormattedLocation() -> String {
        var result = "\(self.name)\n"
        if let address = self.address {
            result += "\(address)\n"
        }
        if let city = self.city, let state = self.state {
            result += "\(city), \(state)"
        } else if let city = self.city {
            result += "\(city)"
        } else if let state = self.state {
            result += "\(state)"
        }
        
        return result
    }
    
    private func getSnapshotter(annotation:FoursquareLocationMapAnnotation) -> MKMapSnapshotter {
        var options = MKMapSnapshotOptions()
        
        var size = CGSizeMake(imageSize.width/3, imageSize.height * 0.85)
        
        options.size = size
        options.scale = UIScreen.mainScreen().scale
        options.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 900.0, 900.0)
        
        return MKMapSnapshotter(options: options)
    }
    
    private func generateVenueMapImage(annotation:FoursquareLocationMapAnnotation, imageMapDelegate:VenueMapImageDelegate, snapshot:MKMapSnapshot, error:NSError?) {
        if let error = error {
            println("Error taking map snapshot image")
        } else {
            var image = snapshot.image
            var annotationView = CategoryPinAnnotationView(annotation: annotation, reuseIdentifier: "foursquarePin")
            annotationView.configure(annotation, scaledImageIdentifier: annotation.categoryImageName8!, size: CGSizeMake(8, 8))
            
            var scale = UIScreen.mainScreen().scale
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(annotationView.image.size.width + 5, annotationView.image.size.height + 10), false, scale)
            var context:CGContextRef = UIGraphicsGetCurrentContext()
            annotationView.drawInContext(context)
            var annotationImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
            image.drawAtPoint(CGPointMake(0, 0))
            
            var point = snapshot.pointForCoordinate(annotation.coordinate)
            var pinCenterOffset = annotationView.centerOffset;
            point.x -= annotationImage.size.width / 2;
            point.y -= annotationImage.size.height / 2;
            //extract the triangle height
            point.y -= annotationView.image.size.height * 0.4
            point.x += pinCenterOffset.x;
            
            point.y += pinCenterOffset.y;
            
            annotationImage.drawAtPoint(point)
            var finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            ImageCache.sharedInstance().storeImage(finalImage, withIdentifier: "venue_map_\(annotation.venueId)")
            
            UIGraphicsEndImageContext()
            
            imageMapDelegate.refreshMapImage()
        }
    }
}
