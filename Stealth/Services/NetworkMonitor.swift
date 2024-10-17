//
//  NetworkMonitor.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/16/24.
//

import Network

class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    // Stores the current status of the network
    var isConnected: Bool = false
    var isExpensive: Bool = false
    
    // Called when network status changes
    var didChangeStatus: ((Bool) -> Void)?
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            self.isExpensive = path.isExpensive
            
            DispatchQueue.main.async {
                self.didChangeStatus?(self.isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    // Function to check if the network is slow (based on network interface type)
    func isSlowConnection() -> Bool {
        if monitor.currentPath.usesInterfaceType(.cellular) {
            // Cellular data is generally slower than WiFi, but this is a basic check
            return true
        }
        return false
    }
    
    // Function to check if the network is expensive (i.e., cellular data)
    func isExpensiveConnection() -> Bool {
        return monitor.currentPath.isExpensive
    }
    
    // Function to stop the monitor if needed
    func stopMonitoring() {
        monitor.cancel()
    }
}

