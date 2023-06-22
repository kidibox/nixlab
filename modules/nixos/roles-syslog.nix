{
  # TODO make this a module?

  networking.firewall.allowedUDPPorts = [ 514 ];

  networking.hosts = {
    # Until reverse DNS works, avoid syslog showing `_gateway` as the host when using `use_dns(yes)`
    "10.0.10.1" = [ "rb5009" ];
  };

  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      options {
        chain_hostnames(no);
        check_hostname(yes);
        keep_hostname(yes);
        use_fqdn(no);
        use_dns(yes);
      };

      source s_internal {
          internal();
      };

      source s_network {
        udp(port(514));
      };

      destination d_loki {
        syslog("localhost" transport("tcp") port(1514));
      };

      log {
        # source(s_internal);
        source(s_network);
        destination(d_loki);
      };
    '';
  };

  # TODO only do this if promtail is enabled?
  services.promtail.configuration.scrape_configs = [
    {
      job_name = "syslog";
      syslog = {
        listen_address = "0.0.0.0:1514";
        idle_timeout = "360s";
        label_structured_data = true;
        use_incoming_timestamp = true;
        labels = {
          job = "syslog";
        };
      };
      relabel_configs = [
        {
          source_labels = [ "__syslog_message_hostname" ];
          target_label = "hostname";
        }
        {
          source_labels = [ "__syslog_message_severity" ];
          target_label = "level";
        }
        {
          source_labels = [ "__syslog_message_app_name" ];
          target_label = "application";
        }
        {
          source_labels = [ "__syslog_message_facility" ];
          target_label = "facility";
        }
        {
          regex = "__syslog_message_sd_(.+)";
          action = "labelmap";
          replacement = "sd_$1";
        }
      ];
    }
  ];
}
