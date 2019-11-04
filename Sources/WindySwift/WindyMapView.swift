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
    private var registeredMapIcons: [String: WindyIcon.WindyRepresentation]

    // MARK: - Public variables

    public var isWindyLogoVisible: Bool {
        didSet {
            updateWindyLogoVisibility()
        }
    }

    public private(set) var isZooming: Bool = false

    public private(set) var isMoving: Bool = false

    @IBOutlet public weak var delegate: WindyMapViewDelegate?

    // MARK: - Init

    public override init(frame: CGRect) {
        self.isWindyLogoVisible = true
        self.registeredMapIcons = [:]

        super.init(frame: frame)
        initialize()
    }

    public required init?(coder: NSCoder) {
        self.isWindyLogoVisible = true
        self.registeredMapIcons = [:]

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

}

extension WindyMapView {

    public func panTo(coordinate: CLLocationCoordinate2D, options: WindyZoomPanOptions? = nil) {
        let optionsString = options?.jsonString() ?? "{}"
        let javascript =
        """
        globalMap.panTo(new L.LatLng(\(coordinate.latitude), \(coordinate.longitude)), \(optionsString));
        """
        webView.evaluateJavaScript(javascript)
    }

    public func setZoom(zoom: Int, options: WindyZoomPanOptions? = nil) {
        let optionsString = options?.jsonString() ?? "{}"
        let javascript =
        """
        globalMap.setZoom(\(zoom), \(optionsString));
        """
        webView.evaluateJavaScript(javascript)
    }

    public func addMarker(coordinate: CLLocationCoordinate2D, iconIdentifier: String) {
        guard let windyIcon = registeredMapIcons[iconIdentifier] else { return }
        let windyIconJSON = windyIcon.jsonString() ?? "{}"
        let javascript =
        """
        var icon = L.icon(\(windyIconJSON));
        L.marker([\(coordinate.latitude), \(coordinate.longitude)], {icon: icon}).addTo(globalMap);
        """
        webView.evaluateJavaScript(javascript)
    }

    public func addMarker(coordinates: [CLLocationCoordinate2D], iconIdentifier: String) {
        for coordinate in coordinates {
            addMarker(coordinate: coordinate, iconIdentifier: iconIdentifier)
        }
    }

    public func fitBounds(coordinates: [CLLocationCoordinate2D]) {
        let simpleCoordinateArray: [[Double]] = coordinates.map({ [$0.latitude, $0.longitude] })
        guard let jsonStringArray = simpleCoordinateArray.jsonString() else { return }
        let javascript = """
        var items = \(jsonStringArray);
        globalMap.fitBounds(items);
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

}

extension WindyMapView {

    public func registerMapIcon(_ icon: WindyIcon, for identifier: String) {
        let windyRepresentation = WindyIcon.WindyRepresentation.from(icon)
        registeredMapIcons[identifier] = windyRepresentation
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
            delegate?.windyMapViewZoomDidInitialize?(self)
        case .zoomstart:
            isZooming = true
            delegate?.windyMapViewZoomDidStart?(self)
        case .zoomend:
            isZooming = false
            delegate?.windyMapViewZoomDidEnd?(self)
        case .movestart:
            isMoving = true
            delegate?.windyMapViewMoveDidStart?(self)
        case .moveend:
            isMoving = false
            delegate?.windyMapViewMoveDidEnd?(self)
        case .zoom:
            delegate?.windyMapViewDidZoom?(self)
        case .move:
            delegate?.windyMapViewDidMove?(self)
        }
    }

}
