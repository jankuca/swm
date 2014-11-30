import Cocoa
import Foundation


class ApplicationDelegate: NSObject, NSApplicationDelegate {
  var win: NSWindow;

  init(window: NSWindow) {
    self.win = window;
  }


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    self.win.title = "App"
  }


  func applicationWillTerminate(aNotification: NSNotification) {
  }
}
