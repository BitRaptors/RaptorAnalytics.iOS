//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import UIKit

@available(iOS 15.0, *)
internal class EventLogUIWindow: UIWindow {

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        frame = UIScreen.main.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let tappableViews = collectTappableViews(view: self)
        
        for tappableView in tappableViews {
            let tappableViewPoint = convert(point, to: tappableView)
            if tappableView.point(inside: tappableViewPoint, with: event) {
                return true
            }
        }
        return true
        return false
    }
    
    internal func collectTappableViews(view: UIView) -> [TappableUIView] {
        
        var tappableViews: [TappableUIView] = []
        if let tappableView = view as? TappableUIView {
            tappableViews.append(tappableView)
        }
        
        for subview in view.subviews {
            tappableViews += collectTappableViews(view: subview)
        }
        
        return tappableViews
    }
    
}
