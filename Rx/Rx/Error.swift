//
//  Error.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let RxErrorDomain       = "RxErrorDomain"
let RxCompositeFailures = "RxCompositeFailures"

public enum RxErrorCode : Int {
    case Unknown   = 0
    case Composite = 1
    case Cast      = 2
    case Disposed  = 3
}

// This defines error type for entire project.
// It's not practical to have different error handling types for different areas of the app.
// This is good enough solution for now unless proven otherwise
public typealias ErrorType = NSError

public let UnknownError  = NSError(domain: RxErrorDomain, code: RxErrorCode.Unknown.rawValue, userInfo: nil)
public let CastError     = NSError(domain: RxErrorDomain, code: RxErrorCode.Cast.rawValue, userInfo: nil)
public let DisposedError = NSError(domain: RxErrorDomain, code: RxErrorCode.Disposed.rawValue, userInfo: nil)

func createCompositeFailure<T>(failures: [Result<T>]) -> Result<T> {
    let description: [NSObject : AnyObject] = [ RxCompositeFailures : Box(failures.map { $0.error! }) ]
    let e = NSError(domain: RxErrorDomain, code: RxErrorCode.Composite.rawValue , userInfo: description)
    
    return .Error(e)
}
