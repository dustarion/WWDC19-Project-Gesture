//
//  View.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 25/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit

public class View: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setViews()
        layoutViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setViews()
        layoutViews()
    }
    
    public func setViews() {
        backgroundColor = .black
    }
    
    public func layoutViews() {}
    
    public var preferredPadding: CGFloat {
        return 20
    }
    
}
