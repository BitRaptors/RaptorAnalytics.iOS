//
//  File.swift
//
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Combine
import Foundation
import SwiftUI

internal enum EventListState: Equatable {
    case closed
    case open
}

@available(iOS 15.0, *)
internal class EventListViewModel: ObservableObject {
    @Published var state: EventListState = .closed

    internal static var shared: EventListViewModel = EventListViewModel()

    @Published var eventsCurrentlyShown: [EventLogData] = []

    func hideEvent(event: EventLogData) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.eventsCurrentlyShown.removeAll { data in
                data.id == event.id
            }
        }
    }
}

@available(iOS 15.0, *)
internal struct EventLogList: View {
    private static let bottomSpacerId = UUID()
    private var eventPublisher = EventLog.shared.eventLogPublisher
    private var newEventPublisher = EventLog.shared.newEventPublisher

    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: EventListViewModel = .shared

    @State private var events: [EventLogData] = []
    @State private var selectedEvent: EventLogData? = nil
    @State private var sheetPresented: Bool = false
    @State private var hideAnimWorkItem: DispatchWorkItem?

    var state: EventListState { viewModel.state }

    public var body: some View {
        ScrollViewReader { scReader in
            GeometryReader { geometryReader in
                switch state {
                case .closed:
                    VStack {
                        ForEach(viewModel.eventsCurrentlyShown) { event in
                            listItem(event: event)
                        }
                        notiIndicator(scrollReader: scReader)
                            .opacity(viewModel.eventsCurrentlyShown.count == 0 ? 1 : 0)
                    }.animation(.easeInOut, value: viewModel.eventsCurrentlyShown)
                case .open:
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Spacer()
                                .frame(minHeight: 0, maxHeight: .infinity)
                            LazyVStack {
                                ForEach(events) { event in
                                    listItem(event: event)
                                        .id(event.id)
                                }
                            }
                            Spacer(minLength: 40).id(Self.bottomSpacerId)
                        }
                        .frame(minHeight: geometryReader.size.height)
                        .animation(.default, value: events)
                    }
                    .transition(.move(edge: .top))
                    .background(AnyShapeStyle(.ultraThinMaterial))
                        .tappable()
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                withAnimation {
                                    viewModel.state = .closed
                                }
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
                        .onReceive(eventPublisher) { eventLogs in
                            events = eventLogs
                            if let log = eventLogs.last {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scReader.scrollTo(log.id)
                                    }
                                }
                            }
                        }
                }
            }
        }.onReceive(newEventPublisher) { newEvent in
            viewModel.eventsCurrentlyShown.append(newEvent)
            viewModel.hideEvent(event: newEvent)
        }
        .background(Color.clear)
        .fullScreenCover(isPresented: $sheetPresented) {
            // On dismiss do nothing
        } content: {
            EventLogDetail(event: $selectedEvent, presented: $sheetPresented)
        }
    }

    let bottomSpacerId = "bottomkurva"

    @ViewBuilder
    private func notiIndicator(scrollReader: ScrollViewProxy) -> some View {
        VStack {
            Button {
                withAnimation {
                    viewModel.state = .open
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollReader.scrollTo(Self.bottomSpacerId)
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

    @ViewBuilder
    private func listItem(event: EventLogData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
            if let message = event.message, event.type == .message {
                Text(LocalizedStringKey(message))
                    .font(Font.system(.subheadline, design: .default))
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(16)
        .padding([.leading, .trailing], 16)
        .onTapGesture {
            selectedEvent = event
            sheetPresented = true
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                print(value.translation)
                switch (value.translation.width, value.translation.height) {
                case (-100 ... 100, ...0):
                    withAnimation {
                        viewModel.eventsCurrentlyShown = []
                    }
                case (-100 ... 100, 0...):
                    withAnimation {
                        viewModel.state = .open
                    }
                default: print("no clue")
                }
            })
        .tappable()
    }
}
