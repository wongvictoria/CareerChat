//
//  Double+roundTo.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/27/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation

extension Double {
    func roundTo(places: Int) -> Double {
        let tenToPower = pow(10.0, Double((places >= 0 ? places: 0)))
        let roundedValue = (self * tenToPower).rounded() / tenToPower
        return roundedValue
    }
}
