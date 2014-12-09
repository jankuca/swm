
class ListCommandResult: CommandResult {
  var dependencies: [String:DependencyState];

  override init(success: Bool) {
    self.dependencies = [String:DependencyState]();
    super.init(success: success);
  }


  func addDependency(
      name: String,
      needs_install: Bool = false,
      needs_build: Bool = false) {
      // children: [String:DependencyState]?) {
    let state = DependencyState();
    state.needs_install = needs_install;
    state.needs_build = needs_build;
    // if let children = children {
      // state.children = children;
    // }

    self.dependencies[name] = state;
  }


  override func render() -> String {
    var output = "";
    output += self.renderDependencySubtree_();

    return output;
  }


  func renderDependencySubtree_(
      dependency_name: String? = nil, prefix: String = "| ") -> String {
    var output = "";
    for (name, state) in self.dependencies {
      output += self.escape("2;37") + prefix + self.escape("0");
      output += name;
      if state.needs_install {
        output += " " + self.escape("0;31") + "(needs install)" + self.escape("0");
      } else if state.needs_build {
        output += " " + self.escape("0;31") + "(needs build)" + self.escape("0");
      }
      output += "\n";
    }

    return output;
  }
}
