//
//  WindyMapAnnotation.swift
//  WindySwift
//
//  Created by Christoph Pageler on 06.11.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation
import CoreLocation


open class WindyMapAnnotation {

    internal let uuid: UUID

    public var coordinate: CLLocationCoordinate2D
    public var icon: WindyIcon

    public init(coordinate: CLLocationCoordinate2D, icon: WindyIcon) {
        self.coordinate = coordinate
        self.icon = icon
        self.uuid = UUID()
    }

}


extension WindyMapAnnotation: Equatable {

    public static func == (lhs: WindyMapAnnotation, rhs: WindyMapAnnotation) -> Bool {
        return lhs.uuid == rhs.uuid
    }

}
