//
//  WindyMapView.swift
//  WindySwift
//
//  Created by Christoph Pageler on 16.10.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import UIKit
import WebKit
import CoreLocation


public class WindyMapView: UIView {

    // MARK: - Private variables

    private let webView = FullScreenWKWebView()
    private var didFinishInitialNavigation: Bool = false

    // MARK: - Public variables

    public var isWindyLogoVisible: Bool {
        didSet {
            updateWindyLogoVisibility()
        }
    }

    public private(set) var isZooming: Bool = false

    public private(set) var isMoving: Bool = false

    public weak var delegate: WindyMapViewDelegate?

    public var annotations: [WindyMapAnnotation] { annotationViews.map { $0.annotation } }

    private var annotationViews: [WindyMapAnnotationView] = []

    // MARK: - Init

    public override init(frame: CGRect) {
        self.isWindyLogoVisible = true

        super.init(frame: frame)
        initialize()
    }

    public required init?(coder: NSCoder) {
        self.isWindyLogoVisible = true

        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        backgroundColor = .black

        webView.configuration.userContentController.add(self, name: "windyMapView")

        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(webView)
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: webView.leftAnchor),
            topAnchor.constraint(equalTo: webView.topAnchor),
            rightAnchor.constraint(equalTo: webView.rightAnchor),
            bottomAnchor.constraint(equalTo: webView.bottomAnchor)
        ])
    }

    public func initialize(apiKey: String) {
        initialize(options: .withKey(apiKey))
    }

    public func initialize(options: WindyInitOptions) {
        let html = WindyHTML.indexHTML(options: options)
        let htmlData = html.data(using: .utf8)

        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let windyIndexURL = tempDirectory.appendingPathComponent("windy.html")
        try? htmlData?.write(to: windyIndexURL)
        webView.loadFileURL(windyIndexURL, allowingReadAccessTo: windyIndexURL)
    }

    private func updateWindyLogoVisibility() {
        guard didFinishInitialNavigation else { return }
        let addOrRemove = isWindyLogoVisible ? "remove" : "add"
        let javascript =
        """
        var bodyElement = document.querySelector("body");
        bodyElement.classList.\(addOrRemove)("windy-logo-invisible");
        """
        webView.evaluateJavaScript(javascript)
    }

    private func decodedJavaScriptObject<T: Codable>(any: Any?) -> T? {
        guard let bodyDict = any as? NSDictionary else { return nil }
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else { return nil }
        guard let javaScriptObject = try? JSONDecoder().decode(T.self, from: bodyData) else { return nil }
        return javaScriptObject
    }

}

// MARK: - Windy Map Methods

public struct WindyZoomPanOptions: Codable {

    public let animate: Bool?
    public let duration: Double?
    public let easeLinearity: Double?
    public let noMoveStart: Bool?

    public init(animate: Bool? = nil, duration: Double? = nil, easeLinearity: Double? = nil, noMoveStart: Bool? = nil) {
        self.animate = animate
        self.duration = duration
        self.easeLinearity = easeLinearity
        self.noMoveStart = noMoveStart
    }

    public static func animate(_ animate: Bool) -> WindyZoomPanOptions {
        return WindyZoomPanOptions(animate: animate)
    }

}

extension WindyMapView {

    public func panTo(coordinate: CLLocationCoordinate2D, options: WindyZoomPanOptions? = nil) {
        let optionsString = options?.jsonString() ?? "{}"
        let javascript =
        """
        globalMap.panTo(new L.LatLng(\(coordinate.latitude), \(coordinate.longitude)), \(optionsString));
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    public func setZoom(zoom: Int, options: WindyZoomPanOptions? = nil) {
        let optionsString = options?.jsonString() ?? "{}"
        let javascript =
        """
        globalMap.setZoom(\(zoom), \(optionsString));
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    public func setMinZoom(minZoom: Int) {
        let javascript =
        """
        globalMap.setMinZoom(\(minZoom));
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    public func setMaxZoom(maxZoom: Int) {
        let javascript =
        """
        globalMap.setMaxZoom(\(maxZoom));
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    private func addMarker(annotationView: WindyMapAnnotationView) {
        let coordinate = annotationView.annotation.coordinate
        let windyIcon = WindyIcon.WindyRepresentation.from(annotationView.icon)
        let windyIconJSON = windyIcon.jsonString() ?? "{}"

        let javascript =
        """
        var icon = L.icon(\(windyIconJSON));
        var marker = L.marker([\(coordinate.latitude), \(coordinate.longitude)], {icon: icon});
        marker.uuid = "\(annotationView.annotation.uuid.uuidString)";
        marker.addTo(globalMap);
        marker.on('click', function(e) {
            sendNativeMessage('markerclick', {
                bounds: globalMap.getBounds(),
                uuid: this.uuid
            });
        });
        markers[marker.uuid] = marker;
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    private func removeMarker(annotationView: WindyMapAnnotationView) {
        let javascript = """
        var marker = markers["\(annotationView.annotation.uuid.uuidString)"];
        if (marker) {
            globalMap.removeLayer(marker);
        }
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    public func fitBounds(coordinates: [CLLocationCoordinate2D]) {
        let simpleCoordinateArray: [[Double]] = coordinates.map({ [$0.latitude, $0.longitude] })
        guard let jsonStringArray = simpleCoordinateArray.jsonString() else { return }
        let javascript = """
        var items = \(jsonStringArray);
        globalMap.fitBounds(items);
        0;
        """
        webView.evaluateJavaScript(javascript)
    }

    public func getCenter(closure: @escaping (CLLocationCoordinate2D?) -> Void) {
        let javascript = """
        globalMap.getCenter();
        """
        webView.evaluateJavaScript(javascript) { (result, error) in
            guard let windyCoordinate: WindyCoordinates = self.decodedJavaScriptObject(any: result) else {
                closure(nil)
                return
            }
            let cordinate = CLLocationCoordinate2D(latitude: windyCoordinate.lat, longitude: windyCoordinate.lng)
            closure(cordinate)
        }
    }

    public func getZoom(closure: @escaping (Int?) -> Void) {
        let javascript = """
        globalMap.getZoom();
        """
        webView.evaluateJavaScript(javascript) { (result, error) in
            closure(result as? Int)
        }
    }

}

// MARK: - Annotations

extension WindyMapView {

    public func addAnnotation(_ annotation: WindyMapAnnotation) {
        addAnnotations([annotation])
    }

    public func addAnnotations(_ annotations: [WindyMapAnnotation]) {
        for annotation in annotations {
            guard !self.annotations.contains(annotation) else { continue }
            guard let annotationView = delegate?.windyMapView(self, viewFor: annotation) else { continue }
            self.annotationViews.append(annotationView)
            addMarker(annotationView: annotationView)
        }
    }

    public func removeAnnotation(_ annotation: WindyMapAnnotation) {
        removeAnnotations([annotation])
    }

    public func removeAnnotations(_ annotations: [WindyMapAnnotation]) {
        for annotation in annotations {
            guard let annotationViewIndex = self.annotationViews.firstIndex(where: { $0.annotation == annotation }) else {
                continue
            }
            removeMarker(annotationView: self.annotationViews[annotationViewIndex])
            self.annotationViews.remove(at: annotationViewIndex)
        }
    }

    private func handleMarkerClick(uuid: UUID) {
        guard let annotationView = annotationViews.first(where: { $0.annotation.uuid == uuid }) else { return }
        delegate?.windyMapView(self, didSelect: annotationView)
    }

    /// Converts annotation to center point
    public func convert(_ annotation: WindyMapAnnotation, closure: @escaping (CGPoint?) -> Void) {
        guard annotations.contains(annotation) else {
            closure(nil)
            return
        }

        let javascript = """
        var marker = markers["\(annotation.uuid.uuidString)"];
        if (marker) {
            globalMap.latLngToContainerPoint(marker.getLatLng());
        } else {
            0;
        }
        """

        webView.evaluateJavaScript(javascript) { (result, error) in
            closure((self.decodedJavaScriptObject(any: result) as WindyPoint?)?.point())
        }
    }

}

// MARK: - WKNavigationDelegate

extension WindyMapView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishInitialNavigation = true
        updateWindyLogoVisibility()
    }

}


extension WindyMapView: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        guard let windyEventContent: WindyEventContent = decodedJavaScriptObject(any: message.body) else { return }

        switch windyEventContent.name {
        case .initialize:
            delegate?.windyMapViewZoomDidInitialize(self)
        case .zoomstart:
            isZooming = true
            delegate?.windyMapViewZoomDidStart(self)
        case .zoomend:
            isZooming = false
            delegate?.windyMapViewZoomDidEnd(self)
        case .movestart:
            isMoving = true
            delegate?.windyMapViewMoveDidStart(self)
        case .moveend:
            isMoving = false
            delegate?.windyMapViewMoveDidEnd(self)
        case .zoom:
            delegate?.windyMapViewDidZoom(self)
        case .move:
            delegate?.windyMapViewDidMove(self)
        case .markerclick:
            guard let uuid = windyEventContent.options.uuid else { return }
            handleMarkerClick(uuid: uuid)
        }
    }

}
