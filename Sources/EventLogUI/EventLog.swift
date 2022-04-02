//
//  __PROJECT_NAME__.swift
//  __PROJECT_NAME__
//
//  Created by Vekety Robin on Mar 30, 2022.
//  Copyright © 2022 BitRaptors. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

@available(iOS 15.0, *)
public enum EventLogType: CaseIterable {
    case message
    case error
    case warning
    case analytics
}

@available(iOS 15.0, *)
public struct EventLogData: Identifiable, Equatable {
    
    public let id: UUID = UUID()
    let date: Date = Date()
    let title: String
    let message: String?
    let type: EventLogType
    
}

@available(iOS 15.0, *)
public class EventLog {
    
    public static let shared = EventLog()
    private var window: EventLogUIWindow?
    
    @Published
    private var eventLogs: [EventLogData] = []
    public var eventLogPublisher: AnyPublisher<[EventLogData], Never> {
        $eventLogs.eraseToAnyPublisher()
    }
    
    private init() { }
    
    public static func send(title: String, message: String? = nil, type: EventLogType = .analytics) {
        //print("sending \(UUID().uuidString)")
        Self.shared.eventLogs.append(EventLogData(title: title, message: message, type: type))
    }
    
    public static func showLogs(on windowScene: UIWindowScene) {
        Self.shared.showLogs(windowScene)
    }
    
    private func showLogs(_ windowScene: UIWindowScene) {
        window = EventLogUIWindow(windowScene: windowScene)
        let controller = EventLogController()
        window?.rootViewController = controller
        window?.windowLevel = .statusBar
        window?.isHidden = false
    }
    
    private func hideLogs() {
        window?.isHidden = true
        window?.removeFromSuperview()
    }
    
}

@available(iOS 15.0, *)
internal extension EventLogType {
    var height: CGFloat {
        switch self {
        case .message:
            return 80
        default:
            return 40
        }
    }
    
    var iconName: String {
        switch self {
        case .message:
            return "message.fill"
        case .error:
            return "xmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .analytics:
            return "chart.bar.xaxis"
        }
    }
    
    func tintColor(for scheme: ColorScheme) -> Color {
        switch (self, scheme) {
        case (.message, .light):
            return .green
        case (.message, .dark):
            return Color(red: 48.0/255.0, green: 219.0/255.0, blue: 91.0/255.0)
        case (.error, .light):
            return .red
        case (.error, .dark):
            return Color(red: 255.0/255.0, green: 105.0/255.0, blue: 97.0/255.0)
        case (.warning, .light):
            return .yellow
        case (.warning, .dark):
            return Color(red: 255.0/255.0, green: 212.0/255.0, blue: 38.0/255.0)
        case (.analytics, .light):
            return .blue
        case (.analytics, .dark):
            return Color(red: 64.0/255.0, green: 156.0/255.0, blue: 255.0/255.0)
        }
    }
}

@available(iOS 15.0, *)
public struct EventLogUI: View {
    
    private var eventPublisher = EventLog.shared.eventLogPublisher
    
    private let normalHeight: CGFloat = 40
    private let messageHeight: CGFloat = 80
    private let bottomSpacerId = UUID()
    
    @State
    private var hideAnimWorkItem: DispatchWorkItem?
    
    @State
    private var timer = Timer.publish (every: 5, on: .current, in: .common)
    
    @State
    private var cancellable: Cancellable?
    
    @State
    private var timerCancellable: Cancellable? = nil
    
    @State
    var events: [EventLogData] = []
    
    @Environment(\.colorScheme)
    var colorScheme
    
    @State
    private var listClosed: Bool = true
    
    @State
    private var sheetPresented: Bool = false
    
    @State
    private var selectedEvent: EventLogData? = nil
    
    @State
    private var notificationsHidden: Bool = false
    
    private var eventLogDelayedPublisher = EventLog.shared.eventLogPublisher.delay(for: 5, scheduler: RunLoop.main)
    
    public init() { }
    
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
            EventLogSheet(event: $selectedEvent, presented: $sheetPresented)
        }
    }
    
    func hideNotiTimedEvent(delay: Int) {
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
    
    func getOffset(_ geoReader: GeometryProxy, notificationsHidden: Bool) -> CGFloat {
        if notificationsHidden {
            return -geoReader.size.height + 15
        }
        return listClosed ? -geoReader.size.height + heightForType(events.last?.type ?? .message) : 0
    }
    
    func heightForType(_ type: EventLogType) -> CGFloat {
        return type == .message ? 80 : 40
    }
    
    @ViewBuilder
    func listItem(geoReader: GeometryProxy, event: EventLogData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: event.type.iconName)
                    .foregroundColor(event.type.tintColor(for: colorScheme))
                Text(event.title)
                    .font(Font.system(size: 14, weight: .semibold, design: .default))
                Spacer()
                Text(event.date, style: .time)
                    .font(Font.system(.footnote, design: .default))
            }
            .padding(.horizontal, 12)
            if let message = event.message, event.type == .message {
                Text(message)
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

@available(iOS 15.0, *)
struct EventLogSheet: View {
    
    @Binding var event: EventLogData?
    
    @Environment(\.colorScheme)
    var colorScheme
    
    @Binding
    var presented: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .top) {
            if let event = event {
                Text(event.date, format: .dateTime)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: event.type.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(event.type.tintColor(for: colorScheme))
                        Text(event.title)
                            .font(.title2)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    Divider()
                        .padding(.horizontal, 16)
                    if let message = event.message {
                        Text(message)
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
            .tappable()
        }
    }
    
}

@available(iOS 15.0, *)
public class EventLogUIWindow: UIWindow {

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        frame = UIScreen.main.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let eventLogController = rootViewController as? EventLogController else { return false }
        let eventLogControllerPoint = convert(point, to: eventLogController.view)
        let pointIsInside = eventLogController.view.point(inside: eventLogControllerPoint, with: event)
        
        let tappableViews = collectTappableViews(view: self)
        
        for tappableView in tappableViews {
            let tappableViewPoint = convert(point, to: tappableView)
            if tappableView.point(inside: tappableViewPoint, with: event) {
                return true
            }
        }
        
        return false
    }
    
    func collectTappableViews(view: UIView) -> [TappableUIView] {
        
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

@available(iOS 15.0, *)
public class EventLogController: UIHostingController<EventLogUI> {
    
    init() {
        super.init(rootView: EventLogUI())
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

@available(iOS 15.0, *)
internal class TappableUIView: UIView { }

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func tappable(when condition: Bool = true) -> some View {
        self.background(condition ? AnyView(TappableView()) : AnyView(EmptyView()))
    }
}

@available(iOS 15.0, *)
internal struct TappableView: UIViewRepresentable {
    typealias UIViewType = TappableUIView

    func makeUIView(context: Context) -> TappableUIView {
        return TappableUIView()
    }

    func updateUIView(_ uiView: TappableUIView, context: Context) {
        //NOP
    }
}

//@available(iOS 15.0, *)
//internal struct TappableView<Content: View>: UIViewControllerRepresentable {
//
//    let content: Content
//
//    func makeUIViewController(context: Context) -> CustomHostingController<Content> {
//        let controller = CustomHostingController(rootView: content)
//        let size = controller.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        controller.preferredContentSize = size
//        controller.view.backgroundColor = .clear
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: CustomHostingController<Content>, context: Context) {
//        uiViewController.rootView = content
//    }
//}
//
//@available(iOS 15.0, *)
//class CustomHostingController<Content: View>: UIHostingController<Content> {
//
//    let rootHost: UIHostingController<Content>
//
//    override init(rootView: Content) {
//        self.rootHost = UIHostingController(rootView: rootView)
//        super.init(rootView: rootView)
//
//    }
//
//    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func loadView() {
//        self.view = TappableUIView()
//        self.view.addSubview(self.rootHost.view)
//        self.addChild(self.rootHost)
//        self.rootHost.didMove(toParent: self)
//    }
//
//}


//Kind of working

//@available(iOS 15.0, *)
//internal class TappableUIView: UIView { }
//
//@available(iOS 15.0, *)
//extension View {
//    func tappable() -> some View {
//        TappableView(content:self)
//    }
//}
//
//@available(iOS 15.0, *)
//internal struct TappableView<Content: View>: UIViewControllerRepresentable {
//
//    let content: Content
//
//    func makeUIViewController(context: Context) -> CustomHostingController<Content> {
//        let controller = CustomHostingController(rootView: content)
//        let size = controller.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        controller.preferredContentSize = size
//        controller.view.backgroundColor = .clear
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: CustomHostingController<Content>, context: Context) {
//        uiViewController.rootView = content
//    }
//}
//
//@available(iOS 15.0, *)
//class CustomHostingController<Content: View>: UIHostingController<Content> {
//
//    let rootHost: UIHostingController<Content>
//
//    override init(rootView: Content) {
//        self.rootHost = UIHostingController(rootView: rootView)
//        super.init(rootView: rootView)
//
//    }
//
//    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func loadView() {
//        self.view = TappableUIView()
//        self.view.addSubview(self.rootHost.view)
//        self.addChild(self.rootHost)
//        self.rootHost.didMove(toParent: self)
//    }
//
//}
