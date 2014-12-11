
class SignCommandResult: CommandResult {
  var signature_type: String?;
  var certificate: String?;
  var provision: String?


  override func render() -> String {
    var output = "";
    output += self.renderSignatureInfo_();

    return output + super.render();
  }


  func renderSignatureInfo_() -> String {
    var output = "";

    if let signature_type = self.signature_type {
      output += "Signature for \(signature_type)\n";
    } else {
      output += "Signature\n";
    }

    if let certificate = self.certificate {
      output += "  Certificate: \(certificate)\n";
    } else {
      output += "  Certificate: (none)\n";
    }

    if let provision = self.provision {
      output += "  Provisioning Profile: \(provision)\n";
    } else {
      output += "  Provisioning Profile: (none)\n";
    }

    return output;
  }
}
