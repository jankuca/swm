import Foundation;


class SignCommand: Command {
  var module_manager: ModuleManager;
  var compiler: Compiler;
  var file_manager: NSFileManager;
  var tasks: TaskDispatcher;

  init(
      module_manager: ModuleManager,
      compiler: Compiler,
      file_manager: NSFileManager,
      tasks: TaskDispatcher) {
    self.module_manager = module_manager;
    self.compiler = compiler;
    self.file_manager = file_manager;
    self.tasks = tasks;
  }


  override func run(args: [String]) -> CommandResult {
    let sign_target = args[0];
    switch (sign_target) {
    case "device":
      return self.signForDevice_();
    case "store":
      return self.signForStore_();
    default:
      return CommandResult(success: false);
    }
  }


  func signForDevice_() -> SignCommandResult {
    let signature_type = "device";

    let result = SignCommandResult(success: false);
    result.signature_type = signature_type;

    if let (cert_sha, summary) = self.getCertificate_(signature_type) {
      result.certificate = cert_sha;
      if let provision = self.getProvisionName_(signature_type) {
        result.provision = provision;
        result.success = self.signBuild_(
            certificate: cert_sha, provision: provision);
      } else {
        result.success = self.signBuild_(certificate: cert_sha);
      }
    }

    return result;
  }


  func signForStore_() -> SignCommandResult {
    let signature_type = "store";

    let result = SignCommandResult(success: false);
    result.signature_type = signature_type;

    if let (cert_sha, summary) = self.getCertificate_(signature_type) {
      result.certificate = cert_sha;
      result.success = self.signBuild_(certificate: cert_sha);
    }

    return result;
  }


  func getCertificate_(signature_type: String) -> (String, String)? {
    let certificates = self.getInstalledCertificates_();
    let config = self.readSignatureConfig_();
    if let item = config[signature_type] {
      if let cert_sha = item.certificate {
        return (cert_sha, "\(cert_sha) \(certificates[cert_sha])");
      }
    }

    var certificate_options = [String]();
    for (sha, name) in certificates {
      certificate_options.append("\(sha) \(name)");
    }

    if let selected = self.promptWithOptions_("Certificate:",
        options: certificate_options) {
      let certificate_name_parts = selected.componentsSeparatedByString(" ");
      return (certificate_name_parts[0], selected);
    }
    return nil;
  }


  func getProvisionName_(signature_type: String) -> String? {
    let config = self.readSignatureConfig_();
    if let item = config[signature_type] {
      return item.provision;
    }

    let provisions = self.getInstalledProvisions_();
    let provision_name = self.promptWithOptions_("Provisioning Profile:",
        options: provisions);
    return provision_name;
  }


  func readSignatureConfig_() -> [String:SignatureConfig] {
    var config = [String:SignatureConfig]();

    let filename = "\(self.directory)/signatures.json";
    if let data = String(contentsOfFile: filename) {
      let json = JSON.parse(data);
      if json.type != "NSError" {
        for (type, desc) in json {
          let item = SignatureConfig();
          if desc["certificate"].type == "String" {
            let certificate = desc["certificate"];
            item.certificate = "\(certificate)";
          }
          if desc["provision"].type == "String" {
            let provision = desc["provision"];
            item.provision = "\(provision)";
          }
          config["\(type)"] = item;
        }
      }
    }

    return config;
  }


  func getInstalledCertificates_() -> [String:String] {
    var certificates = [String:String]();

    let args = [
      "find-identity",
      "-p", "codesigning",
      "-v",
      "login.keychain"
    ];
    let result = self.tasks.exec("security", args: args);
    if result.code == 0 {
      let lines = result.output.componentsSeparatedByString("\n");
      for line in lines {
        if let item = line.componentsSeparatedByString(") ").last {
          let sha_pattern = "^[A-F0-9]+ ";
          if let sha_match = item.rangeOfString(sha_pattern,
              options: .RegularExpressionSearch) {
            let sha = item.substringWithRange(sha_match);
            let name = item.substringFromIndex(sha_match.endIndex);
            certificates[sha] = name;
          }
        }
      }
    }

    return certificates;
  }


  func getInstalledProvisions_() -> [String] {
    var provisions = [String]();

    if let files = self.file_manager.contentsOfDirectoryAtPath(
        self.getProvisionDirectory_(), error: nil) {
      for file in files as [String] {
        if file.hasSuffix(".mobileprovision") {
          provisions.append(
              file.substringToIndex(advance(file.endIndex, -16)));
        }
      }
    }

    return provisions;
  }


  func promptWithOptions_(question: String, options: [String]) -> String? {
    println(question);
    var id = 1;
    for option in options {
      println("  \(id)) \(option)");
      id += 1;
    }

    if let input = self.prompt_() {
      if let match = input.rangeOfString("\\d+",
          options: .RegularExpressionSearch) {
        if let selected_id = input.substringWithRange(match).toInt() {
          return options[selected_id - 1];
        }
      }
    }
    return nil;
  }


  func prompt_() -> String? {
    var keyboard = NSFileHandle.fileHandleWithStandardInput();
    var inputData = keyboard.availableData;
    return NSString(data: inputData, encoding: NSUTF8StringEncoding);
  }


  func signBuild_(#certificate: String, provision: String? = nil) -> Bool {
    let build_app_filename = "\(self.directory)/build/app.app";
    if let provision = provision {
      let provision_filename = "\(self.getProvisionDirectory_())/\(provision)";
      self.file_manager.copyItemAtPath(provision_filename,
          toPath: "\(build_app_filename)/embedded.mobileprovision",
          error: nil);
    }

    let args = [
      "-s", certificate,
      build_app_filename
    ];
    let result = self.tasks.exec("codesign", args: args);
    if result.code != 0 {
      println(result.output);
    }
    return (result.code == 0);
  }


  func getProvisionDirectory_() -> String {
    return NSHomeDirectory() + "/Library/MobileDevice/Provisioning Profiles";
  }
}
