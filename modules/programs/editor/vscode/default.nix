{
  lib,
  pkgs,
  ...
}:
{
  # copilot + copilot-chat are unfree; they carry the native chat, agent mode
  # and BYOK model management.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-github-copilot-chat"
    ];
  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        # Home-manager normally symlinks settings.json into the read-only nix
        # store, so VS Code cannot save anything you change in the UI -- it
        # fails with EROFS. That is correct for settled config and painful
        # while still tuning.
        #
        # This replaces the symlink with a WRITABLE COPY after activation, so
        # the UI works. The flake still wins: every `nixos-rebuild switch`
        # overwrites the copy with whatever is declared here, so experiments
        # are explicitly temporary and cannot silently become permanent.
        # Anything worth keeping has to be written into this file.
        #
        # The first hook is required: home-manager refuses to link over an
        # unmanaged regular file, so last rebuild's copy must go first.
        home.activation = {
          vscodeUnpinSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
            for f in settings.json keybindings.json mcp.json; do
              p="$HOME/.config/Code/User/$f"
              [ -f "$p" ] && [ ! -L "$p" ] && rm -f "$p"
            done
            true
          '';

          vscodeMutableSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            for f in settings.json keybindings.json mcp.json; do
              p="$HOME/.config/Code/User/$f"
              if [ -L "$p" ]; then
                t="$(readlink -f "$p")"
                rm -f "$p"
                install -m 0644 "$t" "$p"
              fi
            done
          '';
        };
      }
    )
    (_: {
      # VS Code reads MCP servers from ~/.config/Code/User/mcp.json. The
      # settings.json flag chat.mcp.discovery.enabled only turns the feature
      # on -- without this file there is nothing for it to discover.
      #
      # This is the same graphiti server Claude Code uses (see ~/.claude.json),
      # running on management-1 and reachable only over the tailnet. Pointing
      # the editor at it means the in-editor agent shares one knowledge graph
      # with the CLI agent instead of keeping a separate memory.
      xdg.configFile."Code/User/mcp.json".text = builtins.toJSON {
        servers = {
          agent-brain = {
            type = "http";
            url = "https://management-1.tail8cb9b0.ts.net:8443/mcp";
          };
        };
      };
    })
    (_: {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = true;
        # package = pkgs.vscodium;
        package = pkgs.vscode;
        profiles.default = {
          extensions =
            (with pkgs.vscode-extensions; [
              bbenoist.nix
              arrterian.nix-env-selector
              eamodio.gitlens
              github.vscode-github-actions

              # Native chat, agent mode, MCP and BYOK live behind these. "BYOK" means
              # your own API key instead of Copilot's model quota -- it does NOT remove
              # the GitHub sign-in requirement. Keys are entered in the UI and stored
              # in gnome-keyring, never in this file.
              github.copilot
              github.copilot-chat

              # From the video, host side only. Anything needing a language server
              # (prettier, tailwind, mdx, pretty-ts-errors, import-cost) belongs in
              # devcontainer.json instead -- on the host it would run against a
              # toolchain that by rule 1 is not installed here.
              alefragnani.project-manager
              alefragnani.bookmarks
              aaron-bond.better-comments
              streetsidesoftware.code-spell-checker
              usernamehw.errorlens
              github.vscode-pull-request-github
              # The client half of the editor split: attach to a DevPod container
              # or management-1 and run the language servers over there.
              ms-vscode-remote.remote-ssh
              yzhang.markdown-all-in-one
              catppuccin.catppuccin-vsc
              catppuccin.catppuccin-vsc-icons
              # asvetliakov.vscode-neovim
              # vscodevim.vim
              # tamasfe.even-better-toml
              jnoortheen.nix-ide
              # redhat.vscode-yaml
              # vadimcn.vscode-lldb
              # rust-lang.rust-analyzer
              # ms-vscode.cpptools
              # ms-vscode.cmake-tools
              # ms-vscode.makefile-tools
              # ziglang.vscode-zig
              # ms-dotnettools.csharp
              # ms-python.python
              # pkief.material-icon-theme
              # equinusocio.vsc-material-theme
              # dracula-theme.theme-dracula
            ])
            # Not in nixpkgs -- these come from the marketplace overlay.
            ++ (with pkgs.vscode-marketplace; [
              raunofreiberg.vesper
              miguelsolorio.symbols
            ]);
          keybindings = [
            {
              key = "ctrl+q";
              command = "editor.action.commentLine";
              when = "editorTextFocus && !editorReadonly";
            }
            {
              key = "ctrl+s";
              command = "workbench.action.files.saveFiles";
            }
            # Cursor-style AI bindings: ctrl+k inline edit, ctrl+l chat.
            {
              key = "ctrl+k";
              command = "inlineChat.start";
              when = "editorFocus";
            }
            {
              key = "ctrl+l";
              command = "workbench.action.chat.open";
            }
            # New terminal tab in the CURRENT window's panel, not a floating
            # window -- deliberate choice over terminal.newInNewWindow after
            # trying that: a separate OS window per terminal felt like leaving
            # the page, this stays in place like a browser "+" tab.
            {
              key = "ctrl+alt+t";
              command = "workbench.action.terminal.new";
            }
            # For when a floating window IS actually wanted, e.g. dragging a
            # terminal to a second monitor -- redockable, unlike a plain new
            # window, by dragging its tab back onto the main window.
            {
              key = "ctrl+alt+shift+t";
              command = "workbench.action.terminal.moveIntoNewWindow";
            }
            # New file, tab in the CURRENT window -- same reasoning as ctrl+alt+t
            # above: stay on the same page, don't spawn a window.
            {
              key = "ctrl+alt+e";
              command = "workbench.action.files.newUntitledFile";
            }
            # The actual float-out, for when it's wanted -- redockable by
            # dragging its tab back onto the main window.
            {
              key = "ctrl+alt+shift+e";
              command = "workbench.action.moveEditorToNewWindow";
              when = "editorFocus";
            }
          ];
          userSettings = {
            "update.mode" = "none";
            # "extensions.autoUpdate" = false; # Fixes vscode freaking out when theres an update
            "window.titleBarStyle" = "custom"; # needed otherwise vscode crashes, see https://github.com/NixOS/nixpkgs/issues/246509
            # Compact hamburger menu rather than a full menu bar -- closer to Cursor's
            # cleaner title bar. Revert to "classic" if you want the menus back.
            "window.menuBarVisibility" = "compact";
            # 14in laptop screen: opening a file/folder from outside an already-open
            # window (Finder, `code <path>`, a devpod launch) should pop a new OS
            # window rather than hijack whatever window is already in front of you.
            "window.openFilesInNewWindow" = "on";
            "window.openFoldersInNewWindow" = "on";
            # New windows open maximized instead of some small remembered size --
            # matters on a small screen where a half-size new window is useless.
            "window.newWindowDimensions" = "maximized";
            # "window.zoomLevel" = 0.5;
            "editor.fontSize" = 15;
            "workbench.colorTheme" = "Vesper";
            "workbench.iconTheme" = "symbols";
            "catppuccin.accentColor" = "mauve";
            "vsicons.dontShowNewVersionMessage" = true;
            "explorer.confirmDragAndDrop" = false;
            "editor.fontLigatures" = true;
            "workbench.startupEditor" = "none";
            "telemetry.enableCrashReporter" = false;
            "telemetry.enableTelemetry" = false;

            "security.workspace.trust.untrustedFiles" = "open";

            "git.enableSmartCommit" = true;
            "git.autofetch" = true;
            "git.confirmSync" = false;
            "gitlens.hovers.annotations.changes" = false;
            "gitlens.hovers.avatars" = false;

            "editor.semanticHighlighting.enabled" = true;
            "gopls" = {
              "ui.semanticTokens" = true;
            };

            "editor.codeActionsOnSave" = {
              "source.organizeImports" = "explicit";
            };
            "editor.inlineSuggest.enabled" = true;
            "editor.formatOnSave" = true;
            # "editor.formatOnType" = true;
            "editor.formatOnPaste" = true;

            # Minimap on: it doubles as a scrollbar preview for long files.
            "editor.minimap.enabled" = true;
            # Cursor layout: files stay on the LEFT (same as stock VS Code). Cursor's
            # actual difference is the activity bar sitting horizontally ABOVE the
            # explorer rather than as a tall vertical strip. The AI chat is what
            # lives on the right, in the secondary sidebar.
            "workbench.sideBar.location" = "left";
            "workbench.activityBar.orientation" = "horizontal";
            "editor.wordWrap" = "on";
            "editor.cursorSmoothCaretAnimation" = "on";
            "editor.cursorBlinking" = "phase";
            # Cursor keeps files on the left and chat on the right. VS Code puts
            # chat in the secondary sidebar, which reproduces that split.
            "workbench.secondarySideBar.defaultVisibility" = "visible";
            "chat.agent.enabled" = true;
            "chat.mcp.discovery.enabled" = true;
            # "workbench.activityBar.location" = "hidden";
            # "workbench.editor.showTabs" = "single";
            # "workbench.statusBar.visible" = false;
            "workbench.layoutControl.type" = "menu";
            "workbench.editor.limit.enabled" = true;
            "workbench.editor.limit.value" = 10;
            "workbench.editor.limit.perEditorGroup" = true;
            "explorer.openEditors.visible" = 0;
            "breadcrumbs.enabled" = false;
            "editor.renderControlCharacters" = false;
            "editor.stickyScroll.enabled" = false; # Top code preview
            "editor.scrollbar.verticalScrollbarSize" = 2;
            "editor.scrollbar.horizontalScrollbarSize" = 2;
            "editor.scrollbar.vertical" = "hidden";
            "editor.scrollbar.horizontal" = "hidden";
            "workbench.layoutControl.enabled" = false;

            "editor.mouseWheelZoom" = true;

            # Terminals as full editor-area tabs (horizontal strip, + button,
            # ctrl+w closes) instead of the bottom panel's tiny side-list --
            # same tab paradigm as the editor and as Orca's terminal.
            "terminal.integrated.defaultLocation" = "editor";
            # WebGL terminal renderer (the "auto" default) breaks in floating/new
            # windows on some drivers -- glyphs partially render or blend into the
            # background. Forcing the DOM renderer trades a little perf for
            # correctness. https://github.com/microsoft/vscode/issues/163936
            "terminal.integrated.gpuAcceleration" = "off";
            # Orca keeps long terminal history; VS Code defaults to 1000 lines.
            "terminal.integrated.scrollback" = 20000;
            "terminal.integrated.enablePersistentSessions" = true;
            # Stop the italic "preview" tab replacing itself as you click around.
            "workbench.editor.enablePreview" = false;

            "C_Cpp.autocompleteAddParentheses" = true;
            "C_Cpp.formatting" = "vcFormat";
            "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyFunction" = true;
            "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyType" = true;
            "C_Cpp.vcFormat.space.beforeEmptySquareBrackets" = true;
            "C_Cpp.vcFormat.newLine.beforeOpenBrace.block" = "sameLine";
            "C_Cpp.vcFormat.newLine.beforeOpenBrace.function" = "sameLine";
            "C_Cpp.vcFormat.newLine.beforeElse" = false;
            "C_Cpp.vcFormat.newLine.beforeCatch" = false;
            "C_Cpp.vcFormat.newLine.beforeOpenBrace.type" = "sameLine";
            "C_Cpp.vcFormat.space.betweenEmptyBraces" = true;
            "C_Cpp.vcFormat.space.betweenEmptyLambdaBrackets" = true;
            "C_Cpp.vcFormat.indent.caseLabels" = true;
            "C_Cpp.intelliSenseCacheSize" = 2048;
            "C_Cpp.intelliSenseMemoryLimit" = 2048;
            "C_Cpp.default.browse.path" = [
              "\${workspaceFolder}/**"
            ];
            "C_Cpp.default.cStandard" = "gnu11";
            "C_Cpp.inlayHints.parameterNames.hideLeadingUnderscores" = false;
            "C_Cpp.intelliSenseUpdateDelay" = 500;
            "C_Cpp.workspaceParsingPriority" = "medium";
            "C_Cpp.clang_format_sortIncludes" = true;
            "C_Cpp.doxygen.generatedStyle" = "/**";

            "vim.leader" = "<Space>";
            "vim.useCtrlKeys" = true;
            "vim.hlsearch" = true;
            "vim.useSystemClipboard" = true;
            "vim.handleKeys" = {
              "<C-f>" = true;
              "<C-a>" = false;
            };
            "vim.insertModeKeyBindings" = [
              {
                "before" = [
                  "k"
                  "j"
                ];
                "after" = [
                  "<Esc>"
                  "l"
                ];
              }
            ];
            "vim.normalModeKeyBindingsNonRecursive" = [
              # NAVIGATION
              # switch b/w buffers
              {
                "before" = [ "<S-h>" ];
                "commands" = [ ":bprevious" ];
              }
              {
                "before" = [ "<S-l>" ];
                "commands" = [ ":bnext" ];
              }

              # splits
              {
                "before" = [
                  "leader"
                  "v"
                ];
                "commands" = [ ":vsplit" ];
              }
              {
                "before" = [
                  "leader"
                  "s"
                ];
                "commands" = [ ":split" ];
              }

              # panes
              {
                "before" = [ "<C-h>" ];
                "commands" = [ "workbench.action.focusLeftGroup" ];
              }
              {
                "before" = [ "<C-j>" ];
                "commands" = [ "workbench.action.focusBelowGroup" ];
              }
              {
                "before" = [ "<C-k>" ];
                "commands" = [ "workbench.action.focusAboveGroup" ];
              }
              {
                "before" = [ "<C-l>" ];
                "commands" = [ "workbench.action.focusRightGroup" ];
              }
              # NICE TO HAVE
              {
                "before" = [
                  "leader"
                  "w"
                ];
                "commands" = [ ":w!" ];
              }
              {
                "before" = [
                  "leader"
                  "q"
                ];
                "commands" = [ ":q!" ];
              }
              {
                "before" = [
                  "leader"
                  "x"
                ];
                "commands" = [ ":x!" ];
              }
              {
                "before" = [
                  "["
                  "d"
                ];
                "commands" = [ "editor.action.marker.prev" ];
              }
              {
                "before" = [
                  "];"
                  "d"
                ];
                "commands" = [ "editor.action.marker.next" ];
              }
              {
                "before" = [
                  "<leader>"
                  "c"
                  "a"
                ];
                "commands" = [ "editor.action.quickFix" ];
              }
              /*
                  {
                  "before" = [":"];
                  "commands" = ["workbench.action.showCommands"];
                }
              */
              {
                "before" = [
                  "<leader>"
                  "f"
                ];
                "commands" = [ "workbench.action.quickOpen" ];
              }
              {
                "before" = [ "<C-n>" ];
                "commands" = [ "workbench.action.toggleSidebarVisibility" ];
              }
              {
                "before" = [
                  "<leader>"
                  "p"
                ];
                "commands" = [ "editor.action.formatDocument" ];
              }
              {
                "before" = [
                  "g"
                  "h"
                ];
                "commands" = [ "editor.action.showDefinitionPreviewHover" ];
              }
            ];
            "vim.visualModeKeyBindings" = [
              # Stay in visual mode while indenting
              {
                "before" = [ "<" ];
                "commands" = [ "editor.action.outdentLines" ];
              }
              {
                "before" = [ ">" ];
                "commands" = [ "editor.action.indentLines" ];
              }
              # Move selected lines while staying in visual mode
              {
                "before" = [ "J" ];
                "commands" = [ "editor.action.moveLinesDownAction" ];
              }
              {
                "before" = [ "K" ];
                "commands" = [ "editor.action.moveLinesUpAction" ];
              }
              # toggle comment selection
              {
                "before" = [
                  "leader"
                  "c"
                ];
                "commands" = [ "editor.action.commentLine" ];
              }
            ];
          };
        };
      };
    })
  ];
}
