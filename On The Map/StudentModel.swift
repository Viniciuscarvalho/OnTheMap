//
//  StudentSingleton.swift
//  On The Map
//
//  Created by Vinicius Carvalho on 12/09/2016.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import Foundation


class StudentModel: NSObject {
    
    var studentLocation = [StudentLocation]()

    class func sharedInstance() -> StudentModel {
        struct Singleton {
            static var sharedInstance = StudentModel()
        }
        return Singleton.sharedInstance
    }
}