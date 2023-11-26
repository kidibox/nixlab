import path = require("path");
import { Construct } from "constructs";
import { DataSopsFile } from "../.gen/providers/sops/data-sops-file";
import * as routeros from "../.gen/providers/routeros/provider";
import { Fn } from "cdktf";

export class RouterosProvider extends Construct {
  secrets: DataSopsFile;
  routeros: any;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    this.secrets = new DataSopsFile(this, "secrets", {
      sourceFile: path.resolve(
        `${__dirname}/../../../configs/home/terraform/secrets.sops.yaml`,
      ),
    });

    this.routeros = new routeros.RouterosProvider(this, "routeros", {
      hosturl: "https://10.99.0.1",
      username: Fn.lookup(this.secrets.data, "routeros_username"),
      password: Fn.lookup(this.secrets.data, "routeros_password"),
      insecure: Fn.lookup(this.secrets.data, "routeros_insecure"),
    });
  }
}
