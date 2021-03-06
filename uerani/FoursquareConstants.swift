//
//  FoursquareConstants.swift
//  uerani
//
//  Created by nacho on 6/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension FoursquareClient {
    
    struct Constants {
        static let BASE_URL = "https://api.foursquare.com/v2/"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let FOURSQUARE_CLIENT_ID = "FZLFHW32I5LGOVAQQMIH330EAN1LGLDHB4B01RUTG5H1DBML"
        static let FOURSQUARE_SECRET = "C2LCOY2E4JEWAEVHK4T1UWETQORWJWO4DL4MX3NANFBXL4Z5"
        static let FORUSQUARE_VERSION = "20150610"
        static let FOURSQUARE_VENUE_LIMIT = "50"
        static let FOURSQUARE_BROWSE_INTENT = "browse"
        static let FOURSQUARE_CALLBACK_URI = "authuerani://uerani/authorized"
        static let FOURSQUARE_AUTHORIZE_URI = "https://foursquare.com/oauth2/authorize"
        static let FOURSQUARE_ACCESS_TOKEN_URI = "https://foursquare.com/oauth2/access_token"
        static let FOURSQUARE = "foursquare"
        
        static let FOURSQUARE_CACHE_DIR = documentsDirectoryURL().URLByAppendingPathComponent("foursquare-cache")
        
        static let FOURSQUARE_USER_ID = "userid"
    }
    
    struct ParameterKeys {
        
        static let LATITUDE_LONGITUDE = "ll"
        static let NEAR = "near"
        static let LL_ACCURACY = "llAcc"
        static let ALTITUDE = "alt"
        static let ALT_ACCURACY = "altAcc"
        static let M = "m"
        static let QUERY = "query"
        static let LIMIT = "limit"
        static let INTENT = "intent"
        static let RADIUS = "radius"
        static let BOUNDING_RECT_SOUTH_WEST = "sw"
        static let BOUNDING_RECT_NORTH_EAST = "sw"
        static let CATEGORY_ID = "categoryId"
        static let URL = "url"
        static let PROVIDER_ID = "providerId"
        static let LINKED_ID = "linkedId"
        static let CLIENT_ID = "client_id"
        static let VERSION = "v"
        static let SW = "sw"
        static let NE = "ne"
        static let FOURSQUARE_OAUTH_TOKEN = "oauth_token"
    }
    
    struct RespnoseKeys {
        static let VENUES = "venues"
        static let VENUE = "venue"
        static let CATEGORIES = "categories"
        static let USER = "user"
        
        static let ErrorDetail = "errorDetail"
        static let ErrorType = "errorType"
        static let Meta = "meta"
        static let Code = "code"
        static let Response = "response"
        
        static let ID = "id"
        static let FIRST_NAME = "firstName"
        static let LAST_NAME = "lastName"
        static let GENDER = "gender"
        static let PHOTO = "photo"
        static let PREFIX = "prefix"
        static let SUFFIX = "suffix"
        static let HOME_CITY = "homeCity"
        static let CONTACT = "contact"
        static let PHONE = "phone"
        static let FORMATED_PHONE = "formated_phone"
        static let EMAIL = "email"
        static let DESCRIPTION = "description"
        static let VENUE_DESCRIPTION = "venueDescription"
        
        static let PHOTOS = "photos"
        static let GROUPS = "groups"
        static let TYPE = "type"
        static let ITEMS = "items"
        static let TAGS = "tags"
        static let TAGVALUE = "tagvalue"
    }
    
    struct Methods {
        static let VENUE_SEARCH = "venues/search"
        static let VENUE_CATEGORY = "venues/categories"
        static let VENUE_DETAIL = "venues/{id}"
        static let USERS_SELF = "users/self"
    }
}
