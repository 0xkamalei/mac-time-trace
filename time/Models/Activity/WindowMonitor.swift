import AppKit
import ApplicationServices
import Foundation

class WindowMonitor {
    static let shared = WindowMonitor()
    
    private init() {}
    
    /// Retrieves the title of the focused window for a given process ID
    /// - Parameter processIdentifier: The PID of the application
    /// - Returns: The window title if available, nil otherwise
    func getActiveWindowTitle(for processIdentifier: pid_t) -> String? {
        // Create accessibility object for the app
        let appElement = AXUIElementCreateApplication(processIdentifier)
        
        var focusedWindow: AnyObject?
        // Get the focused window
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        if result == .success, let window = focusedWindow {
            var title: AnyObject?
            // Get the title of the window
            let titleResult = AXUIElementCopyAttributeValue(window as! AXUIElement, kAXTitleAttribute as CFString, &title)
            
            if titleResult == .success, let titleString = title as? String, !titleString.isEmpty {
                return titleString
            }
        }
        
        return nil
    }
    
    /// Checks if the application has accessibility permissions
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
