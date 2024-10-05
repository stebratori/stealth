//
//  AppReducer.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

// App reducer that combines multiple reducers (if necessary)
func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        chatGPTState: chatGPTReducer(action: action, state: state?.chatGPTState)
    )
}
