{ config, ... }:
{
  sops.secrets."promtail/secrets" = {
    owner = config.systemd.services.promtail.serviceConfig.User;
    group = config.systemd.services.promtail.serviceConfig.Group;
  };

  systemd.services.promtail.serviceConfig.EnvironmentFile = [ "/run/secrets/promtail/secrets" ];

  services.promtail = {
    enable = true;
    extraFlags = [ "-config.expand-env=true" ];
    configuration = {
      server = {
        disable = true;
      };
      clients = [
        {
          url = "https://\${CLIENT_USERNAME}:\${CLIENT_PASSWORD}@logs-prod-eu-west-0.grafana.net/api/prom/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journald";
          journal = {
            max_age = "24h";
            labels = {
              job = "systemd-journal";
            };
          };
          relabel_configs = [
            {
              regex = "__journal__systemd_(.+)";
              action = "labelmap";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "hostname";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "priority";
            }
          ];
        }
      ];
    };
  };
}
