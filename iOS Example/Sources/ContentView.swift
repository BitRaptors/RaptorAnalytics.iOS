//
//  ContentView.swift
//  iOS Example
//
//  Created by Vekety Robin on Mar 30, 2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var taps: Int = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                Image("Home")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Button {
                taps += 1
            } label: {
                Text("Taps: \(taps)")
            }
            .offset(x: -150, y: -370)
        }
        .background(Color(red: 203.0/255, green: 224.0/255, blue: 255.0/255))
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
