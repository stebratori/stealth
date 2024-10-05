//
//  AnonymousStoreSubscriber.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

public class AnonymousStoreSubscriber<SelectedState>: StoreSubscriber {

    // MARK: Lifecycle

    public init(onNewState: @escaping (SelectedState) -> Void) {
        self.onNewState = onNewState
    }

    // MARK: Public

    public typealias StoreSubscriberStateType = SelectedState

    public func newState(state: SelectedState) {
        onNewState(state)
    }

    // MARK: Private

    private let onNewState: (SelectedState) -> Void

}
