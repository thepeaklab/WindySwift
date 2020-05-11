//
//  CopyrightView.swift
//  WindySwift
//
//  Created by Sandro Wehrhahn on 11.05.20.
//  Copyright © 2020 the peak lab. gmbh & co. kg. All rights reserved.
//


import UIKit


class CopyrightView: UIView {

    private var fontSize: CGFloat = 12

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var labelCopyrightIcon: UILabel = {
        let label = UILabel()
        label.text = "©"
        label.font = .systemFont(ofSize: self.fontSize)
        label.textColor = .black
        return label
    }()

    private lazy var labelDescription: UILabel = {
        let label = UILabel()
        label.text = "Contributors"
        label.font = .systemFont(ofSize: self.fontSize)
        label.textColor = .black
        return label
    }()

    private lazy var buttonOSMLink: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: self.fontSize),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.blue
        ]
        button.setAttributedTitle(NSAttributedString(string: "OpenStreetMap", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(openOSMLicenseWebsite), for: .touchUpInside)
        return button
    }()

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

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stackView.addArrangedSubview(labelCopyrightIcon)
        stackView.addArrangedSubview(buttonOSMLink)
        stackView.addArrangedSubview(labelDescription)
    }

    @objc private func openOSMLicenseWebsite() {
        guard let url = URL(string: "https://www.openstreetmap.org/copyright") else { return }
        UIApplication.shared.openURL(url)
    }

}
