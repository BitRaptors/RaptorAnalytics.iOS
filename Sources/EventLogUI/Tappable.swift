//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
internal class TappableUIView: UIView { }

@available(iOS 15.0, *)
internal extension View {
    
    @ViewBuilder
    func tappable(when condition: Bool = true) -> some View {
        self.background(tappableBackground(for: condition))
    }
    
    @ViewBuilder
    private func tappableBackground(for condition: Bool = true) -> some View {
        if condition {
            TappableView()
        } else {
            EmptyView()
        }
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
