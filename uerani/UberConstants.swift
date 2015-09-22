//
//  UberConstants.swift
//  uerani
//
//  Created by nacho on 9/21/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension UberClient {
    
    struct Constants {
        static let BASE_URL = "https://api.uber.com//v1/"
        static let UBER_CLIENT_ID = "kp4tR9HXP1428r0LAmjZMI6PSD4PDirL"
        static let UBER_SECRET = "Ogg3p1FMSu6rQ8awS0OKYNgyr4Cozk3Qa56Dk-9k"
        static let UBER_CALLBACK_URI = "uberauthuerani://uberuerani/authorized"
        static let UBER_AUTHORIZE_URI = "https://login.uber.com/oauth/authorize"
        static let UBER_TOKEN_URI = "https://login.uber.com/oauth/token"
    }
    
    struct ParameterKeys {
        static let START_LATITUDE = "start_latitude"
        static let START_LONGITUDE = "start_longitude"
        static let END_LATITUDE = "end_latitude"
        static let END_LONGITUDE = "end_longitude"
    }
    
    struct ResponseKeys {
        static let PRICES = "prices"
        static let CURRENCY_CODE = "currency_code"
        static let ESTIMATE = "estimate"
    }
    
    struct Methods {
        static let ESTIMATE_PRICE = "estimates/price/"
    }
}
