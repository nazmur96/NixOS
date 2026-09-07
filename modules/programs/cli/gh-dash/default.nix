{ ... }:
{
  home-manager.sharedModules = [
    (_: {
      programs.gh-dash = {
        enable = true;
        settings = {
          prSections = [
            {
              title = "My Pull Requests";
              filters = "is:open author:@me";
            }
            {
              title = "Needs My Review";
              filters = "is:open review-requested:@me";
            }
          ];
          issuesSections = [
            {
              title = "My Issues";
              filters = "is:open author:@me";
            }
            {
              title = "Assigned";
              filters = "is:open assignee:@me";
            }
          ];
        };
      };
    })
  ];
}
