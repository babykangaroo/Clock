//
//  ContentView.swift
//  Clock
//
//  Created by Joey Green on 4/3/22.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    let viewModel: ARVCVM
    var body: some View {
        return ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewControllerRepresentable {
    
    let viewModel: ARVCVM
    
    func makeUIViewController(context: Context) -> ARVC {
        let vc = ARVC(viewModel: viewModel)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ARVC, context: Context) {}

}
