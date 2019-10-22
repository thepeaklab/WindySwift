//
//  FullScreenWKWebView.swift
//  WindySwift
//
//  Created by Christoph Pageler on 22.10.19.
//  Copyright © 2019 the peak lab. gmbh & co. kg. All rights reserved.
//


import Foundation
import WebKit


internal class FullScreenWKWebView: WKWebView {

    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
