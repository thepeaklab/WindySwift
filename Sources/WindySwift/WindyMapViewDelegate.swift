//
//  WindyMapViewDelegate.swift
//  WindySwift
//
//  Created by Christoph Pageler on 04.11.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation


@objc public protocol WindyMapViewDelegate: class {

    @objc optional func windyMapViewZoomDidInitialize(_ windyMapView: WindyMapView)

    @objc optional func windyMapViewZoomDidStart(_ windyMapView: WindyMapView)
    @objc optional func windyMapViewZoomDidEnd(_ windyMapView: WindyMapView)

    @objc optional func windyMapViewMoveDidStart(_ windyMapView: WindyMapView)
    @objc optional func windyMapViewMoveDidEnd(_ windyMapView: WindyMapView)

    @objc optional func windyMapViewDidZoom(_ windyMapView: WindyMapView)
    @objc optional func windyMapViewDidMove(_ windyMapView: WindyMapView)

}
