//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
internal struct EventLogDetail: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding private var event: EventLogData?
    @Binding private var presented: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    internal init(event: Binding<EventLogData?>, presented: Binding<Bool>) {
        self._event = event
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if let event = event {
                Text(event.date, format: .dateTime)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .lineLimit(nil)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: event.type.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(event.type.tintColor(for: colorScheme))
                            .padding(.leading, 8)
                        Text(event.title)
                            .font(.title2)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    Divider()
                        .padding(.horizontal, 16)
                    if let message = event.message {
                        Text(LocalizedStringKey(message))
                            .font(.body)
                            .lineLimit(nil)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 50)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    presented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .background(Circle().fill(.gray))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
            .padding(.trailing, 16)
            //.tappable()
        }
    }
    
}
