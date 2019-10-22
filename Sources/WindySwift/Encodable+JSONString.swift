//
//  Encodable+JSONString.swift
//  WindySwift
//
//  Created by Christoph Pageler on 22.10.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation


internal extension Encodable {

    func jsonString(encoding: String.Encoding = .utf8) -> String? {
        guard let selfData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: selfData, encoding: encoding)
    }

}
