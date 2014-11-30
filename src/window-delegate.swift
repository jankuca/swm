import Cocoa
import Foundation


class WindowDelegate: NSObject, NSWindowDelegate {
  func windowWillClose(notification: NSNotification?) {
    NSApplication.sharedApplication().terminate(0)
  }
}
