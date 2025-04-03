//
//  SwiftUIDebounceTextInput.swift
//
//
//  Created by Alex Nagy on 03.04.2025.
//

import SwiftUI

class DebouncedViewModel: ObservableObject {
    @Published var userInput = ""
}

struct DebouncedModifier: ViewModifier {
    
    @State private var viewModel = DebouncedViewModel()
    
    @Binding var text: String
    @Binding var debouncedText: String
    let debounceSeconds: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .onReceive(
                viewModel.$userInput.debounce(for: RunLoop.SchedulerTimeType.Stride(debounceSeconds), scheduler: RunLoop.main) // Publishes elements only after a specified time interval elapses between events.
            ) { value in
                debouncedText = value
            }
            .onChange(of: text) { _, newValue in
                viewModel.userInput = newValue
            }
    }
}

extension View {
    public func debounced(text: Binding<String>, debouncedText: Binding<String>, debounceSeconds: TimeInterval = 1.0) -> some View {
        modifier(DebouncedModifier(text: text, debouncedText: debouncedText, debounceSeconds: debounceSeconds))
    }
}

struct DebouncedSearchableModifier: ViewModifier {
    
    @State private var text: String = ""
    
    @Binding var debouncedText: String
    let debounceSeconds: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .searchable(text: $text)
            .debounced(text: $text, debouncedText: $debouncedText, debounceSeconds: debounceSeconds)
    }
}

extension View {
    public func searchable(debouncedText: Binding<String>, for debounceSeconds: TimeInterval = 1.0) -> some View {
        self.modifier(DebouncedSearchableModifier(debouncedText: debouncedText, debounceSeconds: debounceSeconds))
    }
}

struct OnDebouncedSearchableModifier: ViewModifier {
    
    @State private var text: String = ""
    @State private var debouncedText: String = ""
    
    let debounceSeconds: TimeInterval
    let onDebounced: (String) -> Void
    
    func body(content: Content) -> some View {
        content
            .searchable(text: $text)
            .debounced(text: $text, debouncedText: $debouncedText, debounceSeconds: debounceSeconds)
            .onChange(of: debouncedText) { _, newValue in
                onDebounced(newValue)
            }
    }
}

extension View {
    public func searchable(for debounceSeconds: TimeInterval = 1.0, onDebounced: @escaping (String) -> Void) -> some View {
        self.modifier(OnDebouncedSearchableModifier(debounceSeconds: debounceSeconds, onDebounced: onDebounced))
    }
}

