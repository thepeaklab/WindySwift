//
//  WindyIcon.swift
//  WindySwift
//
//  Created by Christoph Pageler on 22.10.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation
import CoreGraphics
import UIKit


public struct WindyIcon {

    public enum Icon {

        case url(url: String)
        case image(image: UIImage)

    }

    public let icon: Icon
    public let iconSize: CGSize?
    public let iconAnchor: CGSize?
    public let popupAnchor: CGSize?
    public let shadowUrl: String?
    public let shadowSize: CGSize?
    public let shadowAnchor: CGSize?

    public init(icon: Icon,
                iconSize: CGSize? = nil,
                iconAnchor: CGSize? = nil,
                popupAnchor: CGSize? = nil,
                shadowUrl: String? = nil,
                shadowSize: CGSize? = nil,
                shadowAnchor: CGSize? = nil) {
        self.icon = icon
        self.iconSize = iconSize
        self.iconAnchor = iconAnchor
        self.popupAnchor = popupAnchor
        self.shadowUrl = shadowUrl
        self.shadowSize = shadowSize
        self.shadowAnchor = shadowAnchor
    }

    internal struct WindyRepresentation: Codable {

        internal  let iconUrl: String
        internal  let iconSize: [Int]?
        internal  let iconAnchor: [Int]?
        internal  let popupAnchor: [Int]?
        internal  let shadowUrl: String?
        internal  let shadowSize: [Int]?
        internal  let shadowAnchor: [Int]?

        internal static func from(_ windyIcon: WindyIcon) -> WindyRepresentation {
            let iconURL: String
            var imageSize: CGSize? = nil

            switch windyIcon.icon {
            case .url(let url):
                iconURL = url
            case .image(let image):
                let imageName = "\(UUID().uuidString).png"
                let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
                let data = image.pngData()
                try? data?.write(to: imageURL)
                iconURL = imageURL.path

                imageSize = image.size
            }
            return WindyRepresentation(iconUrl: iconURL,
                                       iconSize: windyIcon.iconSize?.arrayRepresentation() ?? imageSize?.arrayRepresentation(),
                                       iconAnchor: windyIcon.iconAnchor?.arrayRepresentation(),
                                       popupAnchor: windyIcon.popupAnchor?.arrayRepresentation(),
                                       shadowUrl: windyIcon.shadowUrl,
                                       shadowSize: windyIcon.shadowSize?.arrayRepresentation(),
                                       shadowAnchor: windyIcon.shadowAnchor?.arrayRepresentation())
        }

    }

}


internal extension CGSize {

    func arrayRepresentation() -> [Int] {
        return [
            Int(round(width)),
            Int(round(height))
        ]
    }

}
