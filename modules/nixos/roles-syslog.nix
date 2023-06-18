{
  # TODO make this a module

  networking.firewall.allowedTCPPorts = [ 1514 ];

  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      options {
        chain_hostnames(no);
        check_hostname(yes);
        keep_hostname(no);
        use_fqdn(no);
        use_dns(no);
      };

      source s_internal {
          internal();
      };

      source s_network {
        udp(port(1514));
      };

      destination d_loki {
        syslog("localhost" transport("tcp") port(15014));
      };

      log {
        source(s_internal);
        source(s_network);
        destination(d_loki);
      };
    '';
  };

  services.promtail.configuration.scrape_configs = [
    {
      job_name = "syslog";
      syslog = {
        listen_address = "0.0.0.0:15014";
        listen_protocol = "tcp";
        idle_timeout = "60s";
        label_structured_data = true;
        # use_incoming_timestamp = true;
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
          source_labels = [ "__syslog_connection_hostname" ];
          target_label = "syslog_hostname";
        }
        {
          regex = "__syslog_message_(.+)";
          action = "labelmap";
        }
      ];
    }
  ];
}
