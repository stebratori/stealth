//
//  conversationMiddleware.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

// Define the middleware
let conversationMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            if let action = action as? UpdateAudioTextAction {
                // Add the audio text to the conversation as a dictionary with role and content
                var conversation = getState()?.chatGPTState.conversation ?? []
                let newMessage: (role: String, content: String) = (role: "assistant", content: action.audioText)
                conversation.append(newMessage)
                
                // Dispatch an action to update the conversation
                dispatch(UpdateConversationAction(conversation: conversation))
            }
            if let action = action as? SendUserTextAction {
            // Add the user's text to the conversation as a dictionary with role and content
                var conversation = getState()?.chatGPTState.conversation ?? []
                let newMessage: (role: String, content: String) = (role: "user", content: action.text)
                conversation.append(newMessage)
                
                // Dispatch an action to update the conversation
                dispatch(UpdateConversationAction(conversation: conversation))
            }
            
            // Pass the action to the next middleware or reducer
            return next(action)
        }
    }
}
