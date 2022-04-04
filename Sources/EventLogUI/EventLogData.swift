//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation

@available(iOS 15.0, *)
public enum EventLogType: CaseIterable {
    case message
    case error
    case warning
    case analytics
}

@available(iOS 15.0, *)
internal struct EventLogData: Identifiable, Equatable {
    
    public let id: UUID = UUID()
    let date: Date = Date()
    let title: String
    let message: String?
    let type: EventLogType
    
}
