//
//  Extensions.swift
//  swiftyBird
//
//  Created by local192 on 19/02/2020.
//  Copyright © 2020 local192. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(min:CGFloat,max:CGFloat) -> CGFloat {
        return self.random() * (max - min) + min
    }
}
