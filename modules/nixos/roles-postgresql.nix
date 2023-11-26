{
  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [ "kid" "k3s" ];
    ensureUsers = [
      {
        name = "kid";
        ensureDBOwnership = true;
        ensureClauses = {
          superuser = true;
          createrole = true;
          createdb = true;
        };
      }
      {
        name = "k3s";
        ensureDBOwnership = true;
      }
    ];

    authentication = "
      host  kid kid 10.99.0.0/16     trust
      host  k3s k3s 10.0.100.180/31  trust
    ";
  };
}

