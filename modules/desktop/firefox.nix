{
  pkgs, lib, config, ...
}:
with lib;
{

  options.desktop = {
    firefox = mkEnableOption "Enable bare-bones Firefox with my custom settings";
  };

  config = mkIf config.desktop.firefox {
    # from https://wiki.nixos.org/wiki/Firefox#Use_xinput2
    # -> more touchpad gestures and smooth scrolling
    environment.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji  # need emojis sometimes
    ];

    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [
        ".cache/mozilla/firefox"
        ".mozilla/firefox"
      ];
    };

    home-manager.users.${config.core.user} = {
      # I expect this to gradually break/lose effect in the future.
      # For now it works with Firefox 133.0
      # This configuration is based on
      #     https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
      #     https://shen.hong.io/nixos-for-philosophy-installing-firefox-latex-vscodium/
      # For a hard reset of firefox, run `rm -rf ~/.mozilla && rm -rf ~/.cache/mozilla` before rebuilding.
      programs.firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

          settings = {
            # all of the following settings can be found in about:config
            # start pages for new tabs always about:blank (the activity-stream settings are probably not necessary)
            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

            # no search suggestions anymore
            "browser.search.suggest.enabled" = false;
            "browser.search.suggest.enabled.private" = false;
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            "browser.urlbar.sponsoredTopSites" = false;
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.suggest.history" = false;
            "browser.urlbar.suggest.recentsearches" = false;
            "browser.urlbar.suggest.searches" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.clipboard" = false;
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.quickactions" = false;
            "browser.urlbar.suggest.topsites" = false;
            "browser.urlbar.suggest.trending" = false;
            "browser.urlbar.suggest.weather" = false;
            "browser.urlbar.suggest.yelp" = false;
            "browser.urlbar.suggest.mdn" = false;
            "browser.topsites.contile.enabled" = false;

            # remove google branded search bar text
            "browser.urlbar.placeholderName" = "";

            # privacy settings
            "browser.formfill.enable" = false;
            "browser.contentblocking.category" = "strict";

            # no translation suggestions
            "browser.translations.automaticallyPopup" = false;
          };

          search = {
            force = true;
            default = "Google";
            engines = {
              "Google" = {
                urls = [
                  {
                    template = "https://google.com/search?q={searchTerms}";
                  }
                ];
              };
            };
          };
        };

        # policies are more powerful than settings. see:
        #     https://github.com/mozilla/policy-templates
        # for more possibilities
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never";
          DisplayMenuBar = "never";
          SearchBar = "unified";

          # to find the extension id, uncomment the installation_mode, install manually and then check about:support page in the addons section
          ExtensionSettings = {
            "*" = {
              # disable manual installation of extensions
              installation_mode = "blocked";
            };

            # ublock origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
              default_area = "navbar"; # alternatively, "menupanel" will NOT pin the extension
            };

            # bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
              default_area = "navbar";
            };

            # raindrop.io
            "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
              installation_mode = "force_installed";
              default_area = "navbar";
            };
          };
        };
      };
    };
  };

}
