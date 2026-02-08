{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.gh ];

  programs.gitui.enable = true;
  programs.git = {
    enable = true;

    settings.user = {
      name = "Prn-Ice";
      email = "stormprince77@gmail.com";
    };

    # aliases = {
    #   co = "checkout";
    #   pushf = "push --force-with-lease --force-if-includes";
    #   mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
    # };

    # ignores = [
    #   ".DS_Store"
    #   ".svn"
    #   "*~"
    #   "*.swp"
    #   "*.rbc"
    #   ".watsonrc"
    #   ".idea"
    #   ".vscode"
    # ];

    # # see https://github.com/dandavison/delta#get-started
    # delta.enable = true;
    # extraConfig = {
    #   merge.conflictstyle = "diff3";
    #   diff.colorMoved = "default";

    #   merge.tool = "meld";
    #   diff.algorithm = "patience";
    #   pull.ff = "only";
    #   credential.helper = "store";
    #   init.defaultBranch = "main";

    #   # see https://betterprogramming.pub/8-advanced-git-commands-university-wont-teach-you-fe63b483d34b
    #   help.autocorrect = 1;
    #   fetch.prune = true;
    #   push.autoSetupRemote = true;

    #   # see https://michaelheap.com/git-ignore-rev/
    #   blame.ignoreRevsFile = ".git-blame-ignore-revs";

    #   # see https://adamj.eu/tech/2022/10/15/how-to-rebase-stacked-git-branches/
    #   rebase.updateRefs = true;
    # };
  };
}
