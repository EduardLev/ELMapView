//
//  UIViewExtension.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/14/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

extension UIView {
    
    class func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }
}


