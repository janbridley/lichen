//
//  PreviewViewRepresentable.swift
//  Lichen
//
//  SwiftUI wrapper that lets the host app embed the AppKit-based PreviewView.
//

import SwiftUI

struct PreviewViewRepresentable: NSViewRepresentable {

    func makeNSView(context: Context) -> PreviewView { PreviewView() }

    func updateNSView(_ nsView: PreviewView, context: Context) { }
}
