//
//  ContentView.swift
//  iOS Example
//
//  Created by Vekety Robin on Mar 30, 2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ScrollView {
                Image("Home")
            }
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
