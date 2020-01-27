//
//  WindyMapViewDelegate.swift
//  WindySwift
//
//  Created by Christoph Pageler on 04.11.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation


public protocol WindyMapViewDelegate: class {

    func windyMapViewZoomDidInitialize(_ windyMapView: WindyMapView)

    func windyMapViewZoomDidStart(_ windyMapView: WindyMapView)
    func windyMapViewZoomDidEnd(_ windyMapView: WindyMapView)

    func windyMapViewMoveDidStart(_ windyMapView: WindyMapView)
    func windyMapViewMoveDidEnd(_ windyMapView: WindyMapView)

    func windyMapViewDidZoom(_ windyMapView: WindyMapView)
    func windyMapViewDidMove(_ windyMapView: WindyMapView)

    func windyMapView(_ windyMapView: WindyMapView, viewFor annotation: WindyMapAnnotation) -> WindyMapAnnotationView?

    func windyMapView(_ windyMapView: WindyMapView, didSelect annotationView: WindyMapAnnotationView)

}


public extension WindyMapViewDelegate {

    func windyMapViewZoomDidInitialize(_ windyMapView: WindyMapView) { }

    func windyMapViewZoomDidStart(_ windyMapView: WindyMapView) { }
    func windyMapViewZoomDidEnd(_ windyMapView: WindyMapView) { }

    func windyMapViewMoveDidStart(_ windyMapView: WindyMapView) { }
    func windyMapViewMoveDidEnd(_ windyMapView: WindyMapView) { }

    func windyMapViewDidZoom(_ windyMapView: WindyMapView) { }
    func windyMapViewDidMove(_ windyMapView: WindyMapView) { }

    func windyMapView(_ windyMapView: WindyMapView, viewFor: WindyMapAnnotation) -> WindyMapAnnotationView? {
        return nil
    }

    func windyMapView(_ windyMapView: WindyMapView, didSelect annotationView: WindyMapAnnotationView) { }

}
