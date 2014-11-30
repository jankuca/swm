import Cocoa


func main() {
  let app = NSApplication.sharedApplication();
  let win = NSWindow(
    contentRect: NSMakeRect(0, 0, 800, 600),
    styleMask: NSTitledWindowMask | NSClosableWindowMask |
        NSMiniaturizableWindowMask | NSResizableWindowMask,
    backing: .Buffered,
    defer: false
  );

  let win_delegate = WindowDelegate();
  let app_delegate = ApplicationDelegate(window: win);

  app.delegate = app_delegate;
  app.setActivationPolicy(NSApplicationActivationPolicy.Regular);

  win.delegate = win_delegate;
  win.center();
  win.makeKeyAndOrderFront(win);

  app.activateIgnoringOtherApps(true);
  app.run();
}


main();
