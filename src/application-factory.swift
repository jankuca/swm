
class ApplicationFactory {
  func createApplication(directory: String) -> Application {
    let app = Application(directory: directory);
    let app_delegate = ApplicationDelegate();

    app.delegate = app_delegate;
    return app;
  }
}
