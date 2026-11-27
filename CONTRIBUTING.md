# Contributing

Thanks for helping. The RBAi CLI is closed source. Its program code isn't in this repository, so we can't take
changes to the program itself, but there is still a lot you can do.

## Report a problem or ask a question

[Open an issue](https://github.com/Insightwithhari/rbai-cli/issues/new/choose) and choose the form that fits. A good
report gives:

- your `rbai --version`, your operating system and how you installed rbai;
- the exact command you ran, or what you typed in the chat;
- what rbai printed, and what you expected instead;
- the output of `rbai doctor`.

Never paste an API key, a sign-in code or a token. For a security problem, follow [SECURITY.md](SECURITY.md)
instead of opening an issue.

## Suggest a change

Pull requests are welcome for:

- the documents written for this repository: `README.md`, `SUPPORT.md`, `CONTRIBUTING.md`, `docs/README.md` and
  `install/README.md`;
- new examples in `examples/`. They must come from real runs: the command, its real output, the rbai version and
  the date;
- mistakes in the documentation, the changelog, the installer scripts or the agent kit.

Some files are copied here from RBAi's own sources with every release, so they stay the same as the program you
install: `CHANGELOG.md`, `LICENSE-CLI.txt`, `LICENSE-KIT.txt`, everything in `docs/` except `docs/README.md`,
`install/install.sh`, `install/install.ps1`, `assets/rbai-mark.svg` and the agent kit (`AGENTS.md`, `GEMINI.md`,
`gemini-extension.json`, `plugin.json`, `mcp.json`, `server.json`, `.claude-plugin/`, `skills/`, `codex/`,
`cursor/` and `vscode/`). A fix to one of these is made at its source and arrives here with the next release, so we
may close your pull request with a note once the fix is in.

Keep a pull request small, and say what it fixes.

## Licence of contributions

By sending a contribution, you agree that The Dream Lab Innovations may use it in RBAi and in this repository, under
the terms in [LICENSE.md](LICENSE.md).
