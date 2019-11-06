//
//  WindyMapAnnotationView.swift
//  WindySwift
//
//  Created by Christoph Pageler on 06.11.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation


public class WindyMapAnnotationView {

    public var annotation: WindyMapAnnotation

    public var icon: WindyIcon

    public init(annotation: WindyMapAnnotation, icon: WindyIcon) {
        self.annotation = annotation
        self.icon = icon
    }

}
