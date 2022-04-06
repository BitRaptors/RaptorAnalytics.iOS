//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 15.0, *)
internal class EventLogController: UIHostingController<EventLogList> {
    
    init() {
        super.init(rootView: EventLogList())
        view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
