//
//  PreviewViewRepresentable.swift
//  Lichen
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  SwiftUI wrapper that lets the host app embed the AppKit-based PreviewView.
//

import SwiftUI

struct PreviewViewRepresentable: NSViewRepresentable {

    func makeNSView(context: Context) -> PreviewView { PreviewView() }

    func updateNSView(_ nsView: PreviewView, context: Context) { }
}
