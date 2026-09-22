{ ... }:
{
  home-manager.sharedModules = [
    (_: {
      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          scan_timeout = 10;
          format = "$username$hostname\${custom.mise}$directory$git_branch$git_state$git_status$cmd_duration$golang$python$nix_shell$character";
          directory = {
            truncate_to_repo = false;
            read_only = " ro";
            style = "#57C7FF";
            # style = "bold italic bright-blue";
          };
          /*
               username = {
              style_user = "green bold";
              style_root = "red bold";
              format = "[$user]($style)";
              disabled = false;
              show_always = true;
            };
          */
          character = {
            success_symbol = "[❯](#FF6AC1)";
            error_symbol = "[❯](#FF5C57)";
            vimcmd_symbol = "[❮](bright-green)";
          };
          git_branch = {
            format = "[$branch]($style)";
            symbol = "git ";
            style = "242";
          };
          git_status = {
            format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
            style = "cyan";
            conflicted = "​";
            untracked = "​";
            modified = "​";
            staged = "​";
            renamed = "​";
            deleted = "​";
            stashed = "≡";
          };
          git_state = {
            format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
            style = "bright-black";
          };
          cmd_duration = {
            format = "[$duration]($style) ";
            style = "yellow";
          };
          aws = {
            symbol = "aws ";
          };
          azure = {
            symbol = "az ";
          };
          bun = {
            symbol = "bun ";
          };

          cmake = {
            symbol = "cmake ";
          };
          deno = {
            symbol = "deno ";
          };
          docker_context = {
            symbol = "docker ";
          };
          golang = {
            symbol = "go ";
          };
          # hostname = {
          #   ssh_only = false;
          #   format = " on [$hostname](bold red)\n";
          #   disabled = false;
          # };
          lua = {
            symbol = "lua ";
          };
          nodejs = {
            symbol = "nodejs ";
          };
          memory_usage = {
            symbol = "memory ";
          };
          nim = {
            symbol = "nim ";
          };

          # Shown when mise is providing tools for the current directory --
          # i.e. there is a mise.toml and its tools are on PATH. mise has no
          # "inside": it edits PATH per directory, so without this there is
          # nothing to see and no way to tell it apart from a plain shell.
          # The built-in `mise` module only looks in the CURRENT directory, so it
          # vanished one level down in a project -- right exactly where you stop
          # checking, which is worse than no badge at all.
          #
          # This walks up the tree the way mise itself does. Pure shell, no
          # `mise` call, so it costs one small process per prompt rather than
          # starting a Rust binary.
          custom.mise = {
            description = "Shown when a mise.toml applies here or in any parent";
            when = "d=\"$PWD\"; while [ \"$d\" != \"/\" ]; do [ -f \"$d/mise.toml\" ] || [ -f \"$d/.mise.toml\" ] && exit 0; d=$(dirname \"$d\"); done; exit 1";
            command = "true";
            shell = [ "sh" "-c" ];
            format = "[ mise ]($style) ";
            style = "bg:purple fg:black bold";
          };

          # Shown when INSIDE a nix shell. Different symbol on purpose: nix
          # shell is a subshell you exit; mise is per-directory and you do not.
          nix_shell = {
            symbol = "❄️ ";
            format = "[$symbol]($style)";
          };

          shell = {
            disabled = false;
            style = "cyan";
            bash_indicator = "";
            powershell_indicator = "";
          };

          os.symbols = {
            Alpaquita = "alq ";
            Alpine = "alp ";
            Amazon = "amz ";
            Android = "andr ";
            Arch = "rch ";
            Artix = "atx ";
            CentOS = "cent ";
            Debian = "deb ";
            DragonFly = "dfbsd ";
            Emscripten = "emsc ";
            EndeavourOS = "ndev ";
            Fedora = "fed ";
            FreeBSD = "fbsd ";
            Garuda = "garu ";
            Gentoo = "gent ";
            HardenedBSD = "hbsd ";
            Illumos = "lum ";
            Linux = "lnx ";
            Mabox = "mbox ";
            Macos = "mac ";
            Manjaro = "mjo ";
            Mariner = "mrn ";
            MidnightBSD = "mid ";
            Mint = "mint ";
            NetBSD = "nbsd ";
            NixOS = "nix ";
            OpenBSD = "obsd ";
            OpenCloudOS = "ocos ";
            openEuler = "oeul ";
            openSUSE = "osuse ";
            OracleLinux = "orac ";
            Pop = "pop ";
            Raspbian = "rasp ";
            Redhat = "rhl ";
            RedHatEnterprise = "rhel ";
            Redox = "redox ";
            Solus = "sol ";
            SUSE = "suse ";
            Ubuntu = "ubnt ";
            Unknown = "unk ";
            Windows = "win ";
          };
          package = {
            symbol = "pkg ";
          };
          purescript = {
            symbol = "purs ";
          };
          python = {
            format = "[$virtualenv]($style) ";
            style = "bright-black";
            symbol = "py ";
          };
          rust = {
            symbol = "rs ";
          };
          status = {
            symbol = "[x](bold red) ";
          };
          sudo = {
            symbol = "sudo ";
          };
          terraform = {
            symbol = "terraform ";
          };
          zig = {
            symbol = "zig ";
          };
        };
      };
    })
  ];
}
