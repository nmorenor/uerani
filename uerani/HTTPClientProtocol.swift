//
//  HTTPClientProtocol.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol HTTPClientProtocol {
    
    func getBaseURLSecure() -> String
    func addRequestHeaders(request:NSMutableURLRequest)
    func processJsonBody(jsonBody:[String:AnyObject]) -> [String:AnyObject]
    func processResponse(data:NSData) -> NSData
}
