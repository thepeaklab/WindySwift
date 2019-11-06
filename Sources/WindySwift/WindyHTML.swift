//
//  WindyHTML.swift
//  WindySwift
//
//  Created by Christoph Pageler on 22.10.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation


public struct WindyInitOptions: Codable {

    public let key: String
    public let verbose: Bool?
    public let lat: Double?
    public let lon: Double?
    public let zoom: Int?

    public init(key: String, verbose: Bool? = nil, lat: Double? = nil, lon: Double? = nil, zoom: Int? = nil) {
        self.key = key
        self.verbose = verbose
        self.lat = lat
        self.lon = lon
        self.zoom = zoom
    }

    public static func withKey(_ key: String) -> WindyInitOptions {
        return WindyInitOptions(key: key)
    }

}


internal struct WindyCoordinates: Codable {

    let lat: Double
    let lng: Double

}


internal struct WindyEventContent: Codable {

    let name: EventName
    let options: Options

    enum EventName: String, Codable {

        case initialize

        case zoomstart
        case zoomend
        case movestart
        case moveend

        case zoom
        case move

        case markerclick

    }

    struct Options: Codable {

        let bounds: Bounds
        let uuid: UUID?

        struct Bounds: Codable {

            let northEast: Coordinates
            let southWest: Coordinates

            struct Coordinates: Codable {

                let lat: Double
                let lng: Double

            }

            enum CodingKeys: String, CodingKey {
                case northEast = "_northEast"
                case southWest = "_southWest"
            }

        }

    }

}


internal struct WindyHTML {

    static func indexHTML(options: WindyInitOptions) -> String {
        guard let optionsJSONString = options.jsonString() else { return ""}

        return """
        <html>
            <head>
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0, shrink-to-fit=no"
                />
                <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"></script>
                <script src="https://api4.windy.com/assets/libBoot.js"></script>
                <style>
                    body {
                        padding: 0;
                        margin: 0;
                    }
                    html, body, #windy {
                        height: 100%;
                        width: 100vw;
                    }
                    html body.windy-logo-invisible a#logo {
                        display: none !important;
                    }
                    div#mobile-ovr-select, div#embed-zoom, div#bottom, div#windy-app-promo {
                        display: none !important;
                    }
                </style>
            </head>
            <body>
                <div id="windy"></div>
                <script type="text/javascript">
                    const options = JSON.parse('\(optionsJSONString)');

                    var globalMap;
                    var markers = {};

                    function sendNativeMessage(name, options = {}) {
                        var obj = {
                            name: name,
                            options: options
                        };
                        window.webkit.messageHandlers.windyMapView.postMessage(obj);
                    }

                    // Initialize Windy API
                    windyInit(options, windyAPI => {
                        const { map, broadcast } = windyAPI;
                        globalMap = map;

                        let events = [
                            'zoomstart',
                            'zoomend',
                            'movestart',
                            'moveend',
                            'zoom',
                            'move'
                        ];

                        events.forEach(function(event) {
                            map.on(event, params => {
                                sendNativeMessage(event, {
                                    bounds: map.getBounds()
                                });
                            });
                        });

                        sendNativeMessage('initialize', {
                            bounds: map.getBounds()
                        });
                    });
                </script>
            </body>
        </html>
        """
    }

    static func indexHTML(apiKey: String) -> String {
        return indexHTML(options: .withKey(apiKey))
    }

}
