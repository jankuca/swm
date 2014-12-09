
class InstallCommandResult: CommandResult {
  var dependency_tree: [String:[String]];

  var level_path_ = "./";

  override init(success: Bool) {
    self.dependency_tree = [String:[String]]();
    super.init(success: success);
  }


  func setDependencyTree(dependency_tree: [String:[String]]) {
    self.dependency_tree = dependency_tree;
  }


  override func render() -> String {
    var output = "";
    output += self.renderDependencySubtree_();

    return output + super.render();
  }


  func renderDependencySubtree_(
      dependency_name: String? = nil, prefix: String = "| ") -> String {
    var output = "";
    var names = [String]();
    if let dependency_name = dependency_name {
      if let subtree_keys = self.dependency_tree[dependency_name] {
        names = subtree_keys;
      }
    } else {
      names = Array(self.dependency_tree.keys);
    }

    for name in names {
      let path = "\(self.level_path_)modules/\(name)";
      output += self.escape("2;37") + prefix + self.escape("0");
      output += name;
      output += " " + self.escape("2;37") + path + self.escape("0");
      output += "\n";

      if let children = self.dependency_tree[name] {
        let prev_level_path = self.level_path_;
        self.level_path_ += "modules/\(name)/";
        output += self.renderDependencySubtree_(
            dependency_name: name, prefix: prefix + "| ");
        self.level_path_ = prev_level_path;
      }
    }

    return output;
  }
}
