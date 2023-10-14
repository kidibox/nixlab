{ config, ... }:
{
  sops.secrets."cloudflared/sabnzbd" = {
    owner = config.services.cloudflared.user;
    group = config.services.cloudflared.group;
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "39901638-c9ee-4cf0-a4fb-8d728c62f171" = {
        credentialsFile = "/run/secrets/cloudflared/sabnzbd";
        default = "http_status:404";
        ingress = {
          "ha.kidibox.net" = {
            service = "https://10.0.10.101";
            originRequest = {
              httpHostHeader = "ha.kidibox.net";
              originServerName = "ha.kidibox.net";
            };
          };
          "prowlarr.kidibox.net" = {
            service = "http://10.0.30.110:9696";
          };
          "radarr.kidibox.net" = {
            service = "http://10.0.30.120:7878";
          };
          "sonarr.kidibox.net" = {
            service = "http://10.0.30.130:8989";
          };
          "sabnzbd.kidibox.net" = {
            service = "http://10.0.30.150:8080";
          };
        };
      };
    };
  };
}
