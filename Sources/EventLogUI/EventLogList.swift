//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import SwiftUI
import Combine

@available(iOS 15.0, *)
internal struct EventLogList: View {
    
    private var eventPublisher = EventLog.shared.eventLogPublisher
    
    private let normalHeight: CGFloat = 40
    private let messageHeight: CGFloat = 80
    private let bottomSpacerId = UUID()
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var events: [EventLogData] = []
    @State private var selectedEvent: EventLogData? = nil
    
    @State private var listClosed: Bool = true
    @State private var sheetPresented: Bool = false
    @State private var notificationsHidden: Bool = false
    
    @State private var hideAnimWorkItem: DispatchWorkItem?
    
    public var body: some View {
        ScrollViewReader { scrollReader in
            GeometryReader { geoReader in
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer()
                            .frame(minHeight: 0, maxHeight: .infinity)
                        if !notificationsHidden {
                            LazyVStack {
                                ForEach(events) { event in
                                    listItem(geoReader: geoReader, event: event)
                                }
                            }
                        }
                        if notificationsHidden {
                            VStack {
                                Button {
                                    withAnimation {
                                        listClosed = false
                                        notificationsHidden = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            scrollReader.scrollTo(bottomSpacerId)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "chevron.compact.down")
                                        .antialiased(true)
                                        .resizable()
                                        .frame(width: 60, height: 10)
                                        .foregroundColor(.white)
                                        .font(Font.system(size: 20, weight: .regular, design: .default))
                                }
                                .buttonStyle(.plain)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 3)
                                .padding(.bottom, 4)
                                .contentShape(Rectangle())
                                .tappable()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.clear)
                        }
                        if !listClosed {
                            Spacer(minLength: 40)
                                .id(bottomSpacerId)
                        }
                    }
                    .colorScheme(colorScheme)
                    .frame(minHeight: geoReader.size.height)
                }
                .animation(.default, value: events)
                .offset(y: getOffset(geoReader, notificationsHidden: notificationsHidden))
                .overlay(alignment: .bottomTrailing) {
                    if !listClosed {
                        Button {
                            withAnimation {
                                listClosed = true
                            }
                            hideNotiTimedEvent(delay: 0)
                        } label: {
                            Image(systemName: "arrow.down.right.and.arrow.up.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .background(Circle().fill(.gray))
                        .padding(.trailing, 16)
                        .tappable()
                    }
                }
                .background(listClosed ? AnyShapeStyle(Color.clear) : AnyShapeStyle(.ultraThinMaterial))
                .colorScheme(.dark)
                .tappable(when: !listClosed)
            }
            .onChange(of: events.count) { _ in
                withAnimation {
                    scrollReader.scrollTo(events.last?.id)
                }
            }
            .onReceive(eventPublisher) { eventLogs in
                events = eventLogs
                notificationsHidden = false
                hideNotiTimedEvent(delay: 5)
            }
        }
        .background(Color.clear)
        .fullScreenCover(isPresented: $sheetPresented) {
            // On dismiss do nothing
        } content: {
            EventLogDetail(event: $selectedEvent, presented: $sheetPresented)
        }
    }
    
    private func hideNotiTimedEvent(delay: Int) {
        hideAnimWorkItem?.cancel()
        
        let newHideAnimWorkItem = DispatchWorkItem {
            if listClosed {
                withAnimation {
                    notificationsHidden = true
                }
            }
        }
        
        hideAnimWorkItem = newHideAnimWorkItem
        let deadline = DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(delay))
        DispatchQueue.main.asyncAfter(deadline: deadline,
                                      execute: newHideAnimWorkItem)
    }
    
    private func getOffset(_ geoReader: GeometryProxy, notificationsHidden: Bool) -> CGFloat {
        if notificationsHidden {
            return -geoReader.size.height + 15
        }
        return listClosed ? -geoReader.size.height + heightForType(events.last?.type ?? .message) : 0
    }
    
    func heightForType(_ type: EventLogType) -> CGFloat {
        return type == .message ? 80 : 40
    }
    
    @ViewBuilder
    private func listItem(geoReader: GeometryProxy, event: EventLogData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: event.type.iconName)
                    .foregroundColor(event.type.tintColor(for: colorScheme))
                Text(event.title)
                    .font(Font.system(size: 14, weight: .semibold, design: .default))
                    .lineLimit(1)
                Spacer()
                Text(event.date, style: .time)
                    .font(Font.system(.footnote, design: .default))
            }
            .padding(.horizontal, 12)
            if let message = event.message, event.type == .message {
                Text(LocalizedStringKey(message))
                    .font(Font.system(.subheadline, design: .default))
                    .lineLimit(2)
                    .frame(minWidth: geoReader.size.width - 56, alignment: .leading)
                    .padding(.horizontal, 12)
            }
        }
        .frame(height: heightForType(event.type))
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(16)
        .padding([.leading, .trailing], 16)
        .id(event.id)
        .onTapGesture {
            if listClosed {
                withAnimation {
                    listClosed = false
                }
            } else {
                selectedEvent = event
                sheetPresented = true
            }
        }
        .tappable()
    }
    
}
