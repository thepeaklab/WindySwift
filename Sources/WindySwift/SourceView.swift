//
//  SourceView.swift
//  WindySwift
//
//  Created by Robert Feldhus on 31.08.20.
//  Copyright © 2020 the peak lab. gmbh & co. kg. All rights reserved.
//


import UIKit


class SourceView: UIView {

    private var fontSize: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        layer.cornerRadius = 2

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Source:"
        titleLabel.font = .systemFont(ofSize: self.fontSize)
        titleLabel.textColor = .black
        stackView.addArrangedSubview(titleLabel)

        let buttonSourceLink = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: self.fontSize),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.blue
        ]

        buttonSourceLink.setAttributedTitle(NSAttributedString(string: "Windy.com",
                                                               attributes: attributes),
                                            for: .normal)
        buttonSourceLink.addTarget(self,
                                   action: #selector(buttonSourceLinkTouchUpInside),
                                   for: .touchUpInside)

        stackView.addArrangedSubview(buttonSourceLink)
    }

    @objc func buttonSourceLinkTouchUpInside() {
        guard let url = URL(string: "https://www.windy.com") else { return }
        UIApplication.shared.openURL(url)
    }

}
