# RBAi CLI reference (rbai 1.7.0)

RBAi is a research assistant for the life sciences (https://rbai.thedreamlabinnovations.com). Its command line,
`rbai` (npm package `rbai-cli`), works in the signed-in user's RBAi account: projects, literature reviews,
chats with the RBAi assistant, Galaxy, Structure Studio, slides, Report Writer pages, files and Connect.

This reference is generated from the command registry of rbai 1.7.0 (`rbai help reference`), so it matches
that version exactly. Programs can read the same data as JSON with `rbai commands --json`. For how an AI agent
should use the CLI (sign-in, exit codes, `rbai ask`, recipes), see the agent guide: `rbai help agents`, or
https://rbai.thedreamlabinnovations.com/docs/cli/agents.md.

## Contents

- [Global flags](#global-flags)
- [Output, -o json and --query](#output--o-json-and---query)
- [Exit codes](#exit-codes)
- [Environment variables](#environment-variables)
- [Commands that spend credits](#commands-that-spend-credits)
- [Commands](#commands)

## Global flags

Every command takes these, anywhere on the line (`rbai project list --json`).

| Flag | Type | Description |
| --- | --- | --- |
| `-o, --output <format>` | string: table, json, yaml, tsv | Output format: table (default), json, yaml or tsv |
| `--json` | boolean | Same as -o json |
| `--query <jmespath>` | string | JMESPath expression applied to the data before formatting |
| `--profile <name>` | string | Profile to use (env RBAI_PROFILE) |
| `--api-url <url>` | string | API base URL (env RBAI_API_URL; default https://rbai.thedreamlabinnovations.com/api) |
| `--no-color` | boolean | No colour (also NO_COLOR; FORCE_COLOR forces it) |
| `-q, --quiet` | boolean | Data only: no progress, hints or table headers |
| `--verbose` | boolean | More detail in progress output |
| `--debug` | boolean | Trace every HTTP request on stderr (the key is redacted) |
| `-y, --yes` | boolean | Confirm destructive actions without asking |
| `--no-input` | boolean | Never prompt; fail instead (also when CI is set) |
| `--timeout <seconds>` | number | Per-request timeout in seconds (default 30; 0 = none) |
| `-v, --version` | boolean | Print the version |
| `-h, --help` | boolean | Show help for a command |

## Output, -o json and --query

- stdout carries data only. Progress, hints, warnings and errors go to stderr, so a pipe gets clean data.
- `-o json` prints the API's objects exactly as the server returned them: a list is a JSON array, one item is an
  object, an action prints the server's response. Nothing is cut or renamed, so a field the server adds appears as is.
- `-o yaml` is the same data as YAML; `-o tsv` is one row per item with a header line (none with `-q`); `-o table`
  (the default on a terminal) is for people.
- `--query <jmespath>` applies a JMESPath expression (https://jmespath.org) to the data before formatting:
  `rbai project list -o tsv -q --query "[].id"` prints bare ids.
- With `-o json` (or RBAI_OUTPUT=json) a failure also prints one line on stderr:
  `{"error":{"code":"…","message":"…","status":404,"requestId":"…","hint":"…"}}`.
- `rbai ask`, `rbai galaxy ask` and `rbai connect ask` have their own `--output-format text|json|stream-json`
  (see `rbai ask` below and the agent guide).

## Exit codes

The exit status is the contract; branch on it, never on message text.

| Code | Meaning |
| --- | --- |
| 0 | success |
| 1 | error (other API 4xx, a job that ended failed under --wait, anything unclassified) |
| 2 | usage error (bad arguments or flags, a destructive command without --yes when there is no TTY) |
| 3 | not signed in or not allowed (no API key, HTTP 401, HTTP 403) |
| 4 | not found (HTTP 404) |
| 5 | limit reached (HTTP 402 credits or plan, HTTP 429 rate limit or quota); the server's message is printed |
| 6 | network failure or timeout (no response from the server) |
| 7 | server error (HTTP 5xx) |
| 8 | the agent asked a question, or a Galaxy step waits for the user's approval, and nobody was at the terminal to answer it (rbai ask or rbai galaxy ask without a TTY); answer a question with `rbai ask --session <id> "<answer>"`, and decide an approval in Galaxy Lab on the web |
| 130 | interrupted (Ctrl-C) |

## Environment variables

Precedence for every setting: flag, then environment variable, then the profile's config, then the default.
No `.env` file is read, and no command takes a key as a flag.

| Variable | Meaning |
| --- | --- |
| `RBAI_API_KEY` | An API key (Settings → API keys) used instead of the saved one, for CI, containers, scripts and agents |
| `RBAI_PROFILE` | Profile to use (like --profile) |
| `RBAI_API_URL` | API base URL (like --api-url) |
| `RBAI_WEB_URL` | Web app URL for `open` commands and links (default https://rbai.thedreamlabinnovations.com) |
| `RBAI_OUTPUT` | Default output format: table, json, yaml or tsv |
| `RBAI_CONFIG_DIR` | Config directory (default %APPDATA%\rbai on Windows, $XDG_CONFIG_HOME/rbai or ~/.config/rbai elsewhere) |
| `RBAI_STATE_DIR` | State directory for history, the local action log and undo copies (default %LOCALAPPDATA%\rbai, $XDG_STATE_HOME/rbai or ~/.local/state/rbai) |
| `RBAI_SCREEN_READER` | Set to 1 to make `rbai chat` a plain line-based chat (no redrawing), for screen readers |
| `RBAI_THEME` | Colours for this run: auto, dark, light or mono (else `rbai config set theme`) |
| `RBAI_REDUCED_MOTION` | Set to 1 to keep the spinner still (the folded helix), as the web app does under reduced motion |
| `RBAI_ASCII` | Set to 1 to draw with ASCII only (no Unicode symbols, mark or spinner) |
| `RBAI_NO_UPDATE_CHECK` | Set to 1 to turn off the daily check for a newer rbai (the only request rbai makes besides the RBAi API) |
| `GALAXY_API_KEY` | Galaxy API key for `rbai galaxy` (sent per turn; else the key saved with `rbai galaxy key set`) |
| `HTTPS_PROXY` | Proxy for HTTPS requests, e.g. http://proxy.example.org:8080 (also https_proxy; HTTP_PROXY when unset) |
| `HTTP_PROXY` | Proxy for plain HTTP requests (also http_proxy) |
| `NO_PROXY` | Hosts that skip the proxy, comma-separated: localhost,.example.org (also no_proxy) |
| `NODE_EXTRA_CA_CERTS` | A PEM file of extra CA certificates (a proxy or network that re-signs TLS), read by Node at start |
| `NO_COLOR` | Disable colour (https://no-color.org) |
| `FORCE_COLOR` | Force colour on (1) or off (0) |
| `CI` | When set, the CLI never prompts, never animates and never opens a browser |

## Commands that spend credits

These spend the user's RBAi credits (or a monthly allowance first, then credits). Every other command is free.
`rbai usage show -o json` shows the credits left; `rbai billing plans` the plans and top-ups.

- `rbai chat`: Chat with RBAi in the terminal (the full-screen chat; `rbai` alone opens it too)
- `rbai ask`: Ask RBAi one question and print the answer (for scripts, CI and AI agents; uses credits)
- `rbai review create`: Start a literature review (uses credits)
- `rbai review ask`: Ask a question about a finished review's papers (uses credits)
- `rbai studio create`: Make a Studio output from the project's sources (uses credits)
- `rbai studio retry`: Make a failed Studio output again
- `rbai slides create`: Make a presentation; with a request, the AI builds it (uses credits and a presentation of your month's allowance)
- `rbai slides edit`: Ask the AI to change a presentation (uses credits)
- `rbai structure ask`: Edit with AI: ask Structure Studio to change, analyse or render a structure (uses credits)
- `rbai figure create`: Draw a figure from a review, a project or a page (uses the month's drawings or credits)
- `rbai figure edit`: Ask for a change: draws a new version (uses the month's drawings or credits)
- `rbai figure retry`: Draw a failed figure again
- `rbai plot edit`: Change a chat's figure with AI: the model rewrites its program, the sandbox runs it, the model checks the figure, and it is saved (uses credits)
- `rbai coauthor ask`: Ask the co-author to write in a page (uses credits)
- `rbai galaxy ask`: Give the Galaxy agent a task; live steps on stderr, the answer on stdout (uses credits)
- `rbai galaxy chat`: Chat with the Galaxy agent in the terminal (uses credits)
- `rbai connect ask`: Ask RBAi in Connect (materials, services, collaborators, papers) and print the answer (uses credits)
- `rbai connect chat`: Chat with RBAi in Connect in the terminal (the full-screen chat)
- `rbai researcher labs`: Find labs that used a reagent or method, with the sentence of their paper that shows it, through RBAi in Connect (uses credits)

## Commands

207 commands. Each lists its synopsis, arguments, flags (type and default), whether it needs a key,
changes data, spends credits or can wait, what `-o json` returns where the shape is fixed by the CLI, its MCP tool,
and examples. Exit codes are the table above for every command; `--wait` commands exit 1 when the work ends failed.

- [rbai chat](#cmd-chat)
- [rbai ask](#cmd-ask)
- **rbai specialist**: [list](#cmd-specialist-list), [show](#cmd-specialist-show), [answer](#cmd-specialist-answer), [message](#cmd-specialist-message), [stop](#cmd-specialist-stop)
- [rbai bridge](#cmd-bridge)
- [rbai jobs](#cmd-jobs)
- [rbai tools](#cmd-tools)
- **rbai project**: [list](#cmd-project-list), [show](#cmd-project-show), [create](#cmd-project-create), [update](#cmd-project-update), [delete](#cmd-project-delete), [open](#cmd-project-open), [computer](#cmd-project-computer)
- [rbai link](#cmd-link)
- [rbai unlink](#cmd-unlink)
- **rbai review**: [list](#cmd-review-list), [show](#cmd-review-show), [create](#cmd-review-create), [watch](#cmd-review-watch), [cancel](#cmd-review-cancel), [export](#cmd-review-export), [ask](#cmd-review-ask), [conversation](#cmd-review-conversation), [figures](#cmd-review-figures), [open](#cmd-review-open)
- **rbai session**: [list](#cmd-session-list), [show](#cmd-session-show), [export](#cmd-session-export), [rename](#cmd-session-rename), [delete](#cmd-session-delete), [open](#cmd-session-open), [file](#cmd-session-file), [save](#cmd-session-save), [wait](#cmd-session-wait)
- **rbai source**: [list](#cmd-source-list), [show](#cmd-source-show), [add](#cmd-source-add), [passages](#cmd-source-passages), [download](#cmd-source-download), [retry](#cmd-source-retry), [delete](#cmd-source-delete)
- **rbai studio**: [list](#cmd-studio-list), [show](#cmd-studio-show), [create](#cmd-studio-create), [retry](#cmd-studio-retry), [download](#cmd-studio-download), [delete](#cmd-studio-delete), [templates](#cmd-studio-templates)
- **rbai slides**: [list](#cmd-slides-list), [show](#cmd-slides-show), [create](#cmd-slides-create), [edit](#cmd-slides-edit), [stop](#cmd-slides-stop), [download](#cmd-slides-download), [upload](#cmd-slides-upload), [restore](#cmd-slides-restore), [rename](#cmd-slides-rename), [delete](#cmd-slides-delete)
- **rbai structure**: [show](#cmd-structure-show), [ask](#cmd-structure-ask), [download](#cmd-structure-download)
- **rbai file**: [list](#cmd-file-list), [upload](#cmd-file-upload)
- **rbai library**: [list](#cmd-library-list), [download](#cmd-library-download), [delete](#cmd-library-delete)
- **rbai job**: [list](#cmd-job-list), [show](#cmd-job-show), [watch](#cmd-job-watch), [cancel](#cmd-job-cancel), [delete](#cmd-job-delete), [pause](#cmd-job-pause), [resume](#cmd-job-resume), [download](#cmd-job-download)
- **rbai figure**: [list](#cmd-figure-list), [show](#cmd-figure-show), [create](#cmd-figure-create), [edit](#cmd-figure-edit), [retry](#cmd-figure-retry), [restore](#cmd-figure-restore), [export](#cmd-figure-export), [add-to-page](#cmd-figure-add-to-page), [delete](#cmd-figure-delete)
- **rbai plot**: [edit](#cmd-plot-edit)
- **rbai manuscript**: [list](#cmd-manuscript-list), [show](#cmd-manuscript-show), [append](#cmd-manuscript-append), [export](#cmd-manuscript-export), [delete](#cmd-manuscript-delete), [history](#cmd-manuscript-history), [open](#cmd-manuscript-open), [member list](#cmd-manuscript-member-list), [member add](#cmd-manuscript-member-add), [member update](#cmd-manuscript-member-update), [member remove](#cmd-manuscript-member-remove)
- **rbai coauthor**: [ask](#cmd-coauthor-ask), [list](#cmd-coauthor-list), [show](#cmd-coauthor-show), [cancel](#cmd-coauthor-cancel)
- **rbai galaxy**: [ask](#cmd-galaxy-ask), [chat](#cmd-galaxy-chat), [jobs](#cmd-galaxy-jobs), [histories](#cmd-galaxy-histories), [datasets](#cmd-galaxy-datasets), [download](#cmd-galaxy-download), [workflows](#cmd-galaxy-workflows), [test](#cmd-galaxy-test), [key set](#cmd-galaxy-key-set), [key list](#cmd-galaxy-key-list), [key use](#cmd-galaxy-key-use), [key delete](#cmd-galaxy-key-delete)
- **rbai connect**: [ask](#cmd-connect-ask), [chat](#cmd-connect-chat), [show](#cmd-connect-show), [delete](#cmd-connect-delete), [clear](#cmd-connect-clear)
- **rbai message**: [list](#cmd-message-list), [show](#cmd-message-show), [send](#cmd-message-send), [unread](#cmd-message-unread), [mark-read](#cmd-message-mark-read), [archive](#cmd-message-archive)
- **rbai request**: [list](#cmd-request-list), [show](#cmd-request-show), [update](#cmd-request-update), [delete](#cmd-request-delete), [services](#cmd-request-services)
- **rbai researcher**: [search](#cmd-researcher-search), [labs](#cmd-researcher-labs)
- **rbai skill**: [list](#cmd-skill-list), [show](#cmd-skill-show), [create](#cmd-skill-create), [update](#cmd-skill-update), [delete](#cmd-skill-delete), [preview](#cmd-skill-preview)
- **rbai tool**: [list](#cmd-tool-list), [search](#cmd-tool-search), [show](#cmd-tool-show), [run](#cmd-tool-run), [schemas](#cmd-tool-schemas)
- **rbai connection**: [list](#cmd-connection-list), [add](#cmd-connection-add), [remove](#cmd-connection-remove), [reconnect](#cmd-connection-reconnect), [health](#cmd-connection-health)
- **rbai model**: [list](#cmd-model-list), [set](#cmd-model-set)
- **rbai mcp**: [serve](#cmd-mcp-serve), [config](#cmd-mcp-config), [tools](#cmd-mcp-tools)
- [rbai agent-skill](#cmd-agent-skill)
- [rbai login](#cmd-login)
- [rbai logout](#cmd-logout)
- [rbai whoami](#cmd-whoami)
- **rbai auth**: [login](#cmd-auth-login), [status](#cmd-auth-status), [logout](#cmd-auth-logout), [token](#cmd-auth-token)
- **rbai profile**: [show](#cmd-profile-show), [update](#cmd-profile-update), [effort](#cmd-profile-effort), [page](#cmd-profile-page)
- **rbai usage**: [show](#cmd-usage-show), [storage](#cmd-usage-storage), [compute-credits](#cmd-usage-compute-credits)
- **rbai billing**: [plans](#cmd-billing-plans), [subscription](#cmd-billing-subscription), [history](#cmd-billing-history), [promo](#cmd-billing-promo), [open](#cmd-billing-open)
- **rbai key**: [list](#cmd-key-list), [create](#cmd-key-create), [delete](#cmd-key-delete), [servers](#cmd-key-servers)
- **rbai notification**: [list](#cmd-notification-list), [count](#cmd-notification-count), [read](#cmd-notification-read), [delete](#cmd-notification-delete)
- **rbai memory**: [files](#cmd-memory-files), [read](#cmd-memory-read), [delete-file](#cmd-memory-delete-file), [list](#cmd-memory-list), [enable](#cmd-memory-enable), [disable](#cmd-memory-disable), [delete](#cmd-memory-delete), [clear](#cmd-memory-clear), [project show](#cmd-memory-project-show), [project clear](#cmd-memory-project-clear)
- **rbai config**: [get](#cmd-config-get), [set](#cmd-config-set), [unset](#cmd-config-unset), [list](#cmd-config-list), [profile list](#cmd-config-profile-list), [profile show](#cmd-config-profile-show), [profile use](#cmd-config-profile-use), [profile delete](#cmd-config-profile-delete)
- [rbai api](#cmd-api)
- [rbai commands](#cmd-commands)
- [rbai help](#cmd-help)
- [rbai completion](#cmd-completion)
- [rbai doctor](#cmd-doctor)
- [rbai update](#cmd-update)
- [rbai version](#cmd-version)

<a id="cmd-chat"></a>

## rbai chat

Chat with RBAi in the terminal (the full-screen chat; `rbai` alone opens it too).

```text
rbai chat [prompt...] [flags]
```

The same assistant, tools and conversations as the web app's chat: a conversation started here is listed in the web app (/open opens it there). Enter sends; `\` + Enter, Ctrl-J or Alt-Enter add a line; ↑/↓ history; Tab completes /commands and @files; Esc or Ctrl-C stops an answer (the server stops it too); Ctrl-O shows reasoning and tool details; Ctrl-D or Ctrl-C twice leaves. Type / for the commands: /help /new /resume /project /effort /model /attach /jobs /usage /open /export, the research workflows /review /galaxy /connect /rbai /structure /slides /files /download /skills /tools /memory /link, and /doctor /theme /feedback /login /logout /details /clear /exit; @ attaches a file or tags a tool, skill or database. In a folder (local mode, on by default): RBAi reads, searches and edits the files there and runs commands on this computer, asking first; what it reads is sent to the AI model. The first time in a folder it asks whether it may (remembered per folder). Shift+Tab changes the mode (ask before changes, edit without asking, plan first, read only); /local, /mode, /undo, /rewind and /init manage it; --no-local turns it off for a run. Needs a terminal; scripts and agents use `rbai ask` (or `rbai -p`). Uses credits.

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | A first message, sent as soon as the chat opens |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-p, --project <id>` | string |  | Chat within this project (its sources and memory); default: the profile's project |
| `--attach <file>` | list (repeatable) |  | Attach a local file (up to 25 MB, 8 a message; `@path` in the message works too) |
| `--tool <name>` | list (repeatable, or comma-separated) |  | Have RBAi use this tool (a name from `rbai tool list`); repeatable |
| `--skill <id>` | list (repeatable, or comma-separated) |  | Have RBAi follow this skill (an id from `rbai skill list`); repeatable |
| `--database <name>` | list (repeatable, or comma-separated) |  | Have RBAi query this database through its API (a name from `rbai tool schemas`); repeatable |
| `--session <id>` | string |  | Continue this conversation (`rbai session list` shows them) |
| `-c, --continue` | boolean |  | Continue the most recent conversation |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |
| `--dir <folder>` | string |  | The folder RBAi works in: reads, searches and edits its files and runs commands there, asking first (default: the current folder) |
| `--mode <mode>` | string: ask, edit, plan, read |  | ask (default: asks before changes and commands), edit (edits without asking; commands still ask), plan (reads, then proposes a numbered plan and changes nothing until you say go ahead) or read (only reads and searches); Shift+Tab changes it in the chat |
| `--no-local` | boolean |  | This run, RBAi does not work in a folder (no local files or commands) |
| `-r, --resume` | boolean |  | Choose an earlier conversation to continue (also `rbai -r`) |
| `--plain` | boolean |  | A plain line-based chat with no redrawing (screen readers, dumb terminals; also TERM=dumb or RBAI_SCREEN_READER=1) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: not an MCP tool.

```sh
rbai chat
rbai chat --dir ~/data/kidney-atlas   # Work in another folder (its files, its commands)
rbai chat --mode read   # RBAi only reads and searches this folder
rbai chat --continue   # Pick up the most recent conversation (also `rbai -c`)
rbai chat --resume   # Choose an earlier conversation (also `rbai -r`)
rbai chat --project <id> "Summarise the sources of this project"
rbai chat --plain   # For screen readers
```

<a id="cmd-ask"></a>

## rbai ask

Ask RBAi one question and print the answer (for scripts, CI and AI agents; uses credits).

```text
rbai ask [prompt...] [flags]
```

The prompt comes from the arguments, or from stdin when there are none or it is `-`. The turn is stored like a web chat: stderr names the conversation, and --session <id> or --continue goes on with it. If RBAi asks a question back and nobody is at the terminal, nothing is answered for you: the turn stops and the exit code is 8; answer with `rbai ask --session <id> "<answer>"`. With --no-questions the turn runs without the question tool and asks anything it needs in its answer, so an unattended job never stops on exit 8. A long answer goes on in the background on the server after the first 14 minutes or so; `rbai ask` follows it to its end (stream-json: a `turn-continues` event, then the rest of the answer). While the turn runs, every 30 s a progress line (stderr; stream-json: a `progress` event) says its phase, steps and tool calls as the server last sent them, and when a connection brings only heartbeats, `rbai ask` checks the server's own record of the answer and follows that, so it returns when the server's turn ends. When the answer starts a background job, the job's id and `rbai job watch <id>` are printed; RBAi replies in the chat when the job ends (`rbai session wait <id>`). The answer runs on your account's model (`rbai model`). --tool, --skill and --database pin what the web composer's @-menu pins. With --local, RBAi also works in a folder on this computer (the current one, or --local <folder>) and never asks: it reads, lists and searches files inside it; it uploads them to the chat's cloud sandbox only with --allow upload, edits, writes and downloads files only with --allow edit, and runs commands only with --allow run or --allow "run:<program> <first argument>"; with --allow tools it starts the tool servers of the folder's .mcp.json and your mcp.json (for this run, trusted or not) and uses their tools; anything else goes back to RBAi as not allowed, naming the flag. stream-json then also has local-call and local-result events, and json's toolCalls carry each local call's outcome. Exit codes: `rbai help exit-codes`.

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | The question (or - for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--output-format <format>` | string: text, json, stream-json |  | text (the answer only, default), json (one object at the end) or stream-json (NDJSON events as they stream) |
| `--no-questions` | boolean |  | Run without the question tool: RBAi asks anything it needs in its answer instead of stopping for a reply (CI, cron) |
| `--local [folder]` | string |  | RBAi may read, list and search files in this folder (default: the current one), and with --allow upload them to the chat's cloud sandbox, change them or run commands there; it never asks |
| `--allow <what>` | list (repeatable) |  | With --local: upload (files of the folder to the chat's cloud sandbox), edit (edits, writes and downloads in the folder), run (any command), tools (start the folder's .mcp.json and your mcp.json tool servers and use their tools), or "run:<program> <first argument>" (those commands only) |
| `-p, --project <id>` | string |  | Chat within this project (its sources and memory); default: the profile's project |
| `--attach <file>` | list (repeatable) |  | Attach a local file (up to 25 MB, 8 a message; `@path` in the message works too) |
| `--tool <name>` | list (repeatable, or comma-separated) |  | Have RBAi use this tool (a name from `rbai tool list`); repeatable |
| `--skill <id>` | list (repeatable, or comma-separated) |  | Have RBAi follow this skill (an id from `rbai skill list`); repeatable |
| `--database <name>` | list (repeatable, or comma-separated) |  | Have RBAi query this database through its API (a name from `rbai tool schemas`); repeatable |
| `--session <id>` | string |  | Continue this conversation (`rbai session list` shows them) |
| `-c, --continue` | boolean |  | Continue the most recent conversation |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- `-o json`: --output-format json: one object {sessionId, url, status, text, toolCalls, files, sources, usage, model, exitCode, error, question}; stream-json: one JSON event per line (session, text-delta, reasoning-delta, tool-call, tool-result, local-call, local-result, file, ask-user, turn-continues, progress every 30 s while the turn runs, error), ending with done; json and done carry background {jobs, jobIds, watch, wait} when the answer left work running.
- MCP: not an MCP tool.

```sh
rbai ask "What is the function of BRCA1?"
cat notes.md | rbai ask "Summarise these notes" > summary.md
rbai ask "Name three BRCA1 interactors" --output-format stream-json   # Events as they stream, for agents
rbai ask --no-questions "Draft the weekly summary of project <id>" --project <id>   # An unattended job: no question can stop it
rbai ask --tool uniprot_entry "What does UniProt say about P04637?"   # Pin a tool, as @ in the web composer does
rbai ask --session <id> "Use human GRCh38"   # Answer the question RBAi asked (after exit 8)
rbai ask "Summarise @paper.pdf" --project <id>
rbai ask "Which samples in counts.csv have the lowest library size?" --local   # Read and search the files of this folder
rbai ask --local --allow edit --allow "run:python qc.py" "Find the bug in qc.py, fix it and run it"   # Edit files and run one command, with no prompt
rbai ask --local --allow tools "Look up sample S12 in our LIMS"   # Use the tool servers of this folder's .mcp.json
```

## rbai specialist

A chat's background agents: list, read their reports, answer, message, stop.

<a id="cmd-specialist-list"></a>

### rbai specialist list

The background agents of a chat: their state, credits and latest note.

```text
rbai specialist list <chat>
```

Aliases: `rbai specialist ls`.

| Argument | Required | Description |
| --- | --- | --- |
| `<chat>` | yes | The chat (session) id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: [{id, shortId, name, status, state, outcome, budgetCredits, creditsUsed, minutes, startedAt, deadlineAt, endedAt, steps, toolCalls, latestNote, asking, allowed, error}].
- MCP: `rbai_specialist_list`, served by `rbai mcp serve` by default.

```sh
rbai specialist list cli-1f2e…
rbai specialist list <chat> -o json
```

<a id="cmd-specialist-show"></a>

### rbai specialist show

One agent: its task, latest note, open question and report.

```text
rbai specialist show <id> [flags]
```

Aliases: `rbai specialist view`, `rbai specialist get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | The agent id (rbai specialist list shows it) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--report` | boolean |  | Print its report alone (Markdown), for a file or a pipe |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: {id, name, state, task, notes, report: {text, path, saved}, asking, …}.
- MCP: `rbai_specialist_show`, served by `rbai mcp serve` by default.

```sh
rbai specialist show 3d8d8381-…
rbai specialist show <id> --report > report.md
```

<a id="cmd-specialist-answer"></a>

### rbai specialist answer

Answer an agent that waits for you: its question, or its request for more credits or time.

```text
rbai specialist answer <id> [words...] [flags]
```

An agent that ran short of credits or time asks for more; its card offers: allow the amount it asks for, write the report now (it stops and reports what it has), or stop it. Give one with --choice (and --credits or --minutes for another amount), or answer in your own words, which RBAi reads.

An agent that asks a question gets your words as its answer.

Nothing changes until the server takes the answer: words that choose nothing, or more than one answer may add (1,000 credits, 360 minutes), are refused with the reason, and it still waits.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | The agent id |
| `[words...]` | no | Your answer in words (a question's answer; or, to a request for more, what you want) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--choice <value>` | string: allow, report, stop |  | A request for more: allow, report (write the report now) or stop |
| `--credits <n>` | number |  | With --choice allow: the credits to add (default: what it asks for) |
| `--minutes <n>` | number |  | With --choice allow: the minutes to add (default: what it asks for) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: {answered: true, understood, specialist}.
- MCP: `rbai_specialist_answer` with `rbai mcp serve --tools specialist`.

```sh
rbai specialist answer <id> --choice allow   # Allow the credits or minutes it asks for
rbai specialist answer <id> --choice allow --credits 50   # Allow 50 more credits
rbai specialist answer <id> --choice report   # Have it write its report now
rbai specialist answer <id> "Ashkenazi founder variants only"   # Answer its question
```

<a id="cmd-specialist-message"></a>

### rbai specialist message

Send a running agent a message: it reads it at its next step.

```text
rbai specialist message <id> <text...>
```

Aliases: `rbai specialist steer`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | The agent id |
| `<text...>` | yes | The message |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: {delivered: next-step|answer, understood?, asking?, specialist}.
- MCP: `rbai_specialist_message` with `rbai mcp serve --tools specialist`.

```sh
rbai specialist message <id> "Stop after the first 4, and add each one's chromosome"
```

<a id="cmd-specialist-stop"></a>

### rbai specialist stop

Stop an agent: it ends within seconds and writes its report from what it has.

```text
rbai specialist stop <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | The agent id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: the specialist, after the Stop.
- MCP: `rbai_specialist_stop` with `rbai mcp serve --tools specialist`.

```sh
rbai specialist stop <id>
```

<a id="cmd-bridge"></a>

## rbai bridge

Let a chat on the website work in a folder of this computer (runs until you stop it).

```text
rbai bridge [folder] [flags]
```

Run it in a folder, then choose Work in a folder on my computer in a chat on the website: RBAi reads and searches the folder, and edits files and runs programs there after you approve in the browser. What RBAi reads, and each command's output, is sent to the AI model, as in local mode. The first time, link your browser: in the website, Settings, Your computers, Link this browser, then type y here when the same key shows. Only answers signed by a linked browser approve a change; reads inside the folder and your saved rules run without asking. The same works on a lab's Linux server: run it there, and the website uses that server's folder and processors. Here: /mode, /undo, /rewind, /local log, /local rules, /exit (Ctrl-C asks first while a command runs).

| Argument | Required | Description |
| --- | --- | --- |
| `[folder]` | no | The folder the website may use (default: the current folder) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--mode <mode>` | string: ask, edit, read |  | The most RBAi may do here: ask (default: asks in the browser before changes and commands), edit (edits without asking; commands still ask) or read (only reads and searches). The website can ask for less, never more |
| `--forget-browsers` | boolean |  | Unlink every browser linked with this computer for this account, and stop: no folder is served |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai bridge   # Let the website use the current folder
rbai bridge ~/data/kidney-atlas --mode read   # Another folder, read only
rbai bridge --forget-browsers   # Unlink your browsers from this computer
```

<a id="cmd-jobs"></a>

## rbai jobs

Background jobs RBAi started on this computer: list them, read a log, stop one, clean up.

```text
rbai jobs [action] [id] [flags]
```

A background job is a command RBAi started in a chat in a folder (or with `rbai ask --local --allow run`, or through rbai bridge) that keeps running after the chat, after rbai closes and after its terminal closes. Its output goes to a log file in the CLI's state folder. In a later chat, in any folder, ask RBAi about it ("is my job finished?"): it reads the same records.

A job pauses while the computer sleeps. A restart ends it (Windows updates can restart the computer on their own): it then shows as ended, exit code unknown.

Actions: list (the default: the current folder's jobs, newest first; every folder's with --all); log <id> (the last lines of its log, or lines from --offset); stop <id> (the job and every process it started); clean (removes the jobs that ended more than 7 days ago, and their logs, after asking; nothing is removed on its own).

| Argument | Required | Description |
| --- | --- | --- |
| `[action]` | no | list (default), log, stop or clean |
| `[id]` | no | The job id, for log and stop |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--all` | boolean |  | list: every folder's jobs, not only the current folder's |
| `--lines <n>` | number |  | log: how many lines (default 200, at most 2000) |
| `--offset <line>` | number |  | log: the first line to show, 1-based (default: the last lines) |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- `-o json`: list: [{id, state, exitCode, status, startedAt, endedAt, command, folder, cwd, pid, log, logBytes}]; log: {id, state, from, lines, more, cut, bytes}; stop: the job's row; clean: {removed: [ids]}.
- MCP: not an MCP tool.

```sh
rbai jobs   # This folder's background jobs
rbai jobs --all   # Every folder's
rbai jobs log q7mk   # The last 200 lines of job q7mk's log
rbai jobs log q7mk --offset 1 --lines 50   # Its first 50 lines
rbai jobs stop q7mk   # Stop it and every process it started
rbai jobs clean   # Remove the jobs that ended more than 7 days ago, after asking
```

<a id="cmd-tools"></a>

## rbai tools

Your own tool servers (MCP) for chats in this folder: list them, trust the folder's .mcp.json, forget it.

```text
rbai tools [action]
```

A tool server is an MCP server that you list in the folder's .mcp.json (the format Claude Code uses, so a lab can share one) or in your own mcp.json in the CLI's config folder (every folder). In a chat in the folder, rbai starts them on this computer and RBAi loads their tools when a task needs them; in ask and edit mode it asks you before each call, and in plan and read mode it uses only the tools their server marks read-only. Their environment variables stay on this computer: only the tools' names, descriptions and input schemas go to RBAi.

A folder's servers start only after you trust its .mcp.json once (the chat asks, or rbai tools trust); a changed file asks again. Your own mcp.json needs no trust. rbai ask --local starts them only with --allow tools. rbai bridge asks in its window.

Actions: list (the default: each server, where it is listed, its state and its tools; it starts the servers that may start, lists their tools, and stops them); trust (trust this folder's .mcp.json as it is now); forget (forget this folder's answer about its .mcp.json, and the tools you allowed here without asking).

| Argument | Required | Description |
| --- | --- | --- |
| `[action]` | no | list (default), trust or forget |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- `-o json`: list: [{server, id, source, state, status, runs, tools: [{name, tool, readOnly, description}]}]; trust: {file, sha256, servers}; forget: {folder, forgotten}.
- MCP: not an MCP tool.

```sh
rbai tools   # This folder's tool servers and yours, with their tools
rbai tools trust   # Trust this folder's .mcp.json
rbai tools forget   # Forget it: the next chat asks again
rbai tools -o json   # The same as JSON
```

## rbai project

Research projects.

<a id="cmd-project-list"></a>

### rbai project list

List your projects.

```text
rbai project list [flags]
```

Aliases: `rbai project ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--status <value>` | string: draft, active, archived |  | Only projects with this status |
| `-s, --search <text>` | string |  | Match in the title or description |
| `--sort <value>` | string: updated, created, opened, title | `updated` | Order by |
| `-L, --limit <n>` | number | `50` | Projects per page (at most 100) |
| `--page <n>` | number | `1` | Page number |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_project_list`, served by `rbai mcp serve` by default.

```sh
rbai project list
rbai project list --status active -s crispr
rbai project list -o tsv -q --query "[].id"   # Bare ids
```

<a id="cmd-project-show"></a>

### rbai project show

Show a project.

```text
rbai project show [id]
```

Aliases: `rbai project view`, `rbai project get`.

| Argument | Required | Description |
| --- | --- | --- |
| `[id]` | no | Project id (default: the profile's project) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_project_show`, served by `rbai mcp serve` by default.

```sh
rbai project show 3f2c9e7a-1b2c-4d5e-8f90-0a1b2c3d4e5f
rbai project show <id> -o json
```

<a id="cmd-project-create"></a>

### rbai project create

Create a project.

```text
rbai project create <title> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<title>` | yes | Project name (at most 200 characters) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-d, --description <text>` | string |  | Description (at most 5,000 characters) |
| `--instructions <text|@file>` | string |  | Instructions sent with every chat in the project (@file reads a file) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_project_create`, served by `rbai mcp serve` by default.

```sh
rbai project create "Spike protein variants"
rbai project create "Lab notebook" -d "Weekly results" --instructions @instructions.md
```

<a id="cmd-project-update"></a>

### rbai project update

Change a project's title, description, instructions or status.

```text
rbai project update <id> [flags]
```

Aliases: `rbai project edit`.

Reads the project first and sends its version, as the web app does; exit 1 with a conflict message when it changed meanwhile.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Project id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-t, --title <text>` | string |  | New name |
| `-d, --description <text>` | string |  | New description |
| `--instructions <text|@file>` | string |  | New instructions (@file reads a file) |
| `--status <value>` | string: draft, active, archived |  | New status |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_project_update`, served by `rbai mcp serve` by default.

```sh
rbai project update <id> --status archived
rbai project update <id> --instructions @instructions.md
```

<a id="cmd-project-delete"></a>

### rbai project delete

Delete a project, its sources, Studio outputs and project memory.

```text
rbai project delete <id>
```

Aliases: `rbai project rm`.

The project's chats are kept as normal chats (projects-v2.js, DELETE /projects/:id).

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Project id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_project_delete` with `rbai mcp serve --tools project` `--allow-destructive`.

```sh
rbai project delete <id>
rbai project delete <id> --yes   # In a script
```

<a id="cmd-project-open"></a>

### rbai project open

Open a project in the web app (prints the URL without a terminal).

```text
rbai project open [id] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[id]` | no | Project id (default: the profile's project) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--section <value>` | string: chats, sources, studio, instructions, memory | `chats` | Which part of the project |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai project open <id>
rbai project open <id> --section sources
```

<a id="cmd-project-computer"></a>

### rbai project computer

The project's cloud computer, where its chats run code: its state and disk; --pause or --restart it.

```text
rbai project computer [id] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[id]` | no | Project id (default: the profile's project) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--pause` | boolean |  | Pause it now (its background jobs pause first; a paused computer costs nothing) |
| `--restart` | boolean |  | Restart it from its disk (files are kept; running programs stop) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: the card: its state, size, disk, the plan's count and its jobs.
- MCP: `rbai_project_computer` with `rbai mcp serve --tools project`.

```sh
rbai project computer <id>
rbai project computer <id> --pause
```

<a id="cmd-link"></a>

## rbai link

Link this folder to an RBAi project: commands run here use it.

```text
rbai link [project]
```

Writes .rbai/project.json (the project id and title and the API; no key or token, so it can be committed). Every command run in this folder or below it then uses that project unless --project names another, and `rbai` opens the chat in it. Without an id, on a terminal, choose from your projects.

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | The project id (`rbai project list`); omit it on a terminal to choose |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai link   # Choose one of your projects
rbai link 3f2c9e7a-…   # Link this folder to that project
```

<a id="cmd-unlink"></a>

## rbai unlink

Remove this folder's project link (.rbai/project.json).

```text
rbai unlink
```

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai unlink
```

## rbai review

Literature reviews: start, follow, read, ask.

<a id="cmd-review-list"></a>

### rbai review list

List running and finished literature reviews.

```text
rbai review list [flags]
```

Aliases: `rbai review ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-L, --limit <n>` | number | `20` | Finished reviews to list (at most 100) |
| `--cursor <cursor>` | string |  | Continue after this cursor (printed under the list) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_review_list`, served by `rbai mcp serve` by default.

```sh
rbai review list
rbai review list -o json --query "[?status=='completed'].id"
```

<a id="cmd-review-show"></a>

### rbai review show

Show a literature review (status, papers, query).

```text
rbai review show <id> [flags]
```

Aliases: `rbai review view`, `rbai review get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--text` | boolean |  | Print the review text (Markdown) instead of the summary |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_review_show`, served by `rbai mcp serve` by default.

```sh
rbai review show <id>
rbai review show <id> --text | less
```

<a id="cmd-review-create"></a>

### rbai review create

Start a literature review (uses credits).

```text
rbai review create <question...> [flags]
```

Aliases: `rbai review start`, `rbai review new`.

Returns the review id at once. With --wait, follows the review on stderr until it finishes (exit 1 when it fails or is cancelled).

| Argument | Required | Description |
| --- | --- | --- |
| `<question...>` | yes | The research question (or @file, or - for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-w, --wait` | boolean |  | Wait until the review finishes |
| `--level <level>` | string: low, medium, high, max |  | low, medium, high or max (default: the review's default level); deeper costs more credits |
| `--session <id>` | string |  | Chat session to attach the review to |
| `--idempotency-key <key>` | string |  | A key of your own (8-128 letters, digits, - or _): starting again with it returns the same review |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- `-o json`: {id, status}: status started, or queued when every review slot is busy (it starts when one is free); with --wait, the finished review.
- MCP: `rbai_review_create`, served by `rbai mcp serve` by default.

```sh
rbai review create "Off-target effects of base editors in primary T cells"
rbai review create @question.txt --level high --wait && rbai review export <id> --dest review.md
rbai review create "…" --idempotency-key weekly-2026-11-05   # Safe to retry from a script
```

<a id="cmd-review-watch"></a>

### rbai review watch

Follow a review's progress until it finishes.

```text
rbai review watch <id>
```

Exit 0 when it completed, 1 when it failed or was cancelled.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai review watch <id>
rbai review watch <id> --verbose   # Every status line
```

<a id="cmd-review-cancel"></a>

### rbai review cancel

Stop a running review.

```text
rbai review cancel <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_review_cancel`, served by `rbai mcp serve` by default.

```sh
rbai review cancel <id>
```

<a id="cmd-review-export"></a>

### rbai review export

Write a finished review's text (Markdown) to a file or stdout.

```text
rbai review export <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | File to write (default: stdout) |
| `--format <value>` | string: md, json | `md` | md: the review text; json: the whole review record |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_review_export` with `rbai mcp serve --tools review`.

```sh
rbai review export <id> --dest review.md
rbai review export <id> --format json > review.json
```

<a id="cmd-review-ask"></a>

### rbai review ask

Ask a question about a finished review's papers (uses credits).

```text
rbai review ask <id> <question...> [flags]
```

Streams the answer to stdout. With -o json prints {answer, sources, usage} at the end.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |
| `<question...>` | yes | The question |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this answer (default: the one saved in your account) |
| `--paper <id>` | list (repeatable, or comma-separated) |  | Answer from this paper only (number in the review, DOI, PMID or title); repeatable |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: `rbai_review_ask` with `rbai mcp serve --tools review`.

```sh
rbai review ask <id> "Which papers used primary human T cells?"
rbai review ask <id> "What dose did they use?" --paper 3 --paper 7
```

<a id="cmd-review-conversation"></a>

### rbai review conversation

Show a review's chat conversation, or start a new one (--clear).

```text
rbai review conversation <id> [flags]
```

The questions asked about this review (rbai review ask, or Ask the papers in the web app) with their answers, oldest first. The next question is answered with the last finished ones as its context. --clear deletes them, so the next question starts a new conversation.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Review id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--clear` | boolean |  | Delete the conversation, so the next question starts a new one |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: {messages: [{id, role, content, stopped?, error?, usage?, at}], more}; with --clear, {deleted}.
- MCP: `rbai_review_conversation` with `rbai mcp serve --tools review`.

```sh
rbai review conversation <id>
rbai review conversation <id> --clear --yes
```

<a id="cmd-review-figures"></a>

### rbai review figures

Show or set whether your literature reviews read figures (Pro plan and above).

```text
rbai review figures [state]
```

Saved to your account, as Settings → Model & approvals saves it: every review you start after it follows it, in the CLI and the web app alike. Reading figures costs about a third to a half of a review's credits.

| Argument | Required | Description |
| --- | --- | --- |
| `[state]` | no | on or off (omit to show it) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- `-o json`: {enabled, mayChoose}: whether new reviews read figures, and whether your plan allows them.
- MCP: `rbai_review_figures` with `rbai mcp serve --tools review`.

```sh
rbai review figures
rbai review figures off
```

<a id="cmd-review-open"></a>

### rbai review open

Open Literature reviews in the web app (prints the URL without a terminal).

```text
rbai review open
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai review open
```

## rbai session

Chat sessions: list, read, export, rename, delete, their files, and replies to background work (talk with `rbai chat`).

<a id="cmd-session-list"></a>

### rbai session list

List chat sessions.

```text
rbai session list [flags]
```

Aliases: `rbai session ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--type <value>` | string: all, main, galaxy | `all` | main chats, Galaxy Lab conversations, or both |
| `-L, --limit <n>` | number | `30` | At most this many (newest first) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_session_list`, served by `rbai mcp serve` by default.

```sh
rbai session list
rbai session list --type galaxy -o json
```

<a id="cmd-session-show"></a>

### rbai session show

Show a chat session: its messages as text (or the full record with -o json).

```text
rbai session show <id>
```

Aliases: `rbai session view`, `rbai session get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_session_show`, served by `rbai mcp serve` by default.

```sh
rbai session show <id>
rbai session show <id> -o json --query "messages[-1].rawContent"
```

<a id="cmd-session-export"></a>

### rbai session export

Export a chat session as Markdown or JSON.

```text
rbai session export <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--format <value>` | string: md, json | `md` | File format |
| `--dest <path>` | string |  | File to write (default: stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_session_export` with `rbai mcp serve --tools session`.

```sh
rbai session export <id> --dest chat.md
rbai session export <id> --format json > chat.json
```

<a id="cmd-session-rename"></a>

### rbai session rename

Rename a chat session.

```text
rbai session rename <id> <title...>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |
| `<title...>` | yes | New title (at most 200 characters) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_session_rename` with `rbai mcp serve --tools session`.

```sh
rbai session rename <id> "TP53 variants, follow-up"
```

<a id="cmd-session-delete"></a>

### rbai session delete

Delete a chat session, its files and its background jobs.

```text
rbai session delete <id>
```

Aliases: `rbai session rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_session_delete` with `rbai mcp serve --tools session` `--allow-destructive`.

```sh
rbai session delete <id>
rbai session delete <id> --yes
```

<a id="cmd-session-open"></a>

### rbai session open

Open a chat session in the web app (prints the URL without a terminal).

```text
rbai session open <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_session_open` with `rbai mcp serve --tools session`.

```sh
rbai session open <id>
```

<a id="cmd-session-file"></a>

### rbai session file

Download a file the chat's code sandbox saved (the answer's saved-file link).

```text
rbai session file <id> <name> [flags]
```

Aliases: `rbai session download`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |
| `<name>` | yes | The file name, as the answer names it (results.csv) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: the file name; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_session_file` with `rbai mcp serve --tools session`.

```sh
rbai session file <id> deseq2_results.csv
rbai session file <id> plot.png --dest figures/plot.png
```

<a id="cmd-session-save"></a>

### rbai session save

Download a file an answer links to: a Word or Excel file, a sandbox file, a file or folder on the chat's computer.

```text
rbai session save <link> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<link>` | yes | The link as the answer shows it (/api/chat-files/…), or its full address |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: the file's name here; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: a file: {dest, bytes}; a folder: [{name, type, size, link}].
- MCP: `rbai_session_save` with `rbai mcp serve --tools session`.

```sh
rbai session save "/api/chat-files/stored/<chat>/<sha256>.docx/report.docx"   # A Word file RBAi made
rbai session save "/api/chat-files/computer/<chat>?path=/mnt/data/run/results.tsv"   # A file on the project's computer
rbai session save "/api/chat-files/computer/<chat>?path=/mnt/data/run"   # A folder: lists its files and their links
```

<a id="cmd-session-wait"></a>

### rbai session wait

Wait for RBAi's reply to the chat's background work (an agent's report, a job's end) and print it.

```text
rbai session wait <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Session id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--minutes <n>` | number | `60` | Stop waiting after this many minutes (the work goes on) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: {sessionId, event: {id, events, answerId, noReply}, answerId, status, text}.
- MCP: `rbai_session_wait` with `rbai mcp serve --tools session`.

```sh
rbai session wait <id>   # After an `rbai ask` that started a background agent or job
rbai session wait <id> --minutes 120 -o json
```

## rbai source

A project's sources: files, papers, web pages, text.

<a id="cmd-source-list"></a>

### rbai source list

A project's sources.

```text
rbai source list [project]
```

Aliases: `rbai source ls`.

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_source_list`, served by `rbai mcp serve` by default.

```sh
rbai source list <project id>
```

<a id="cmd-source-show"></a>

### rbai source show

One source, with its extracted text in -o json.

```text
rbai source show <project> <source>
```

Aliases: `rbai source view`, `rbai source get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<source>` | yes | Source id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_source_show`, served by `rbai mcp serve` by default.

```sh
rbai source show <project id> <source id>
```

<a id="cmd-source-add"></a>

### rbai source add

Add a source: a file, a paper (DOI/PMID/arXiv), a web page or text.

```text
rbai source add [project] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--file <path>` | string |  | Upload a local file (PDF, DOCX, CSV, …) |
| `--paper <id>` | string |  | A paper identifier: DOI, PMID or arXiv id |
| `--url <url>` | string |  | A web page |
| `--text <text|@file|->` | string |  | Plain text (@file reads a file, - reads stdin) |
| `--title <text>` | string |  | Title for a web page or text source |
| `-w, --wait` | boolean |  | Wait until it is read and indexed |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_source_add`, served by `rbai mcp serve` by default.

```sh
rbai source add <project id> --file paper.pdf --wait
rbai source add <project id> --paper 10.1038/s41586-020-2012-7
rbai source add <project id> --url https://example.org/protocol --title "Lab protocol"
```

<a id="cmd-source-passages"></a>

### rbai source passages

The indexed passages of a source (what the assistant cites as S<number>).

```text
rbai source passages <project> <source> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<source>` | yes | Source id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--page <n>` | number |  | Only passages on this page |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_source_passages` with `rbai mcp serve --tools source`.

```sh
rbai source passages <project id> <source id> --page 3
```

<a id="cmd-source-download"></a>

### rbai source download

Download a source's original file.

```text
rbai source download <project> <source> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<source>` | yes | Source id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (- for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_source_download` with `rbai mcp serve --tools source`.

```sh
rbai source download <project id> <source id> --dest paper.pdf
```

<a id="cmd-source-retry"></a>

### rbai source retry

Read a failed source again.

```text
rbai source retry <project> <source>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<source>` | yes | Source id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_source_retry` with `rbai mcp serve --tools source`.

```sh
rbai source retry <project id> <source id>
```

<a id="cmd-source-delete"></a>

### rbai source delete

Delete a source and its passages.

```text
rbai source delete <project> <source>
```

Aliases: `rbai source rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<source>` | yes | Source id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_source_delete` with `rbai mcp serve --tools source` `--allow-destructive`.

```sh
rbai source delete <project id> <source id> --yes
```

## rbai studio

A project's Studio outputs: briefs, tables, presentations.

<a id="cmd-studio-list"></a>

### rbai studio list

A project's Studio outputs (briefs, evidence tables, presentations, …).

```text
rbai studio list [project]
```

Aliases: `rbai studio ls`.

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_studio_list`, served by `rbai mcp serve` by default.

```sh
rbai studio list <project id>
```

<a id="cmd-studio-show"></a>

### rbai studio show

One Studio output (with --text: its Markdown content).

```text
rbai studio show <project> <note> [flags]
```

Aliases: `rbai studio view`, `rbai studio get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<note>` | yes | Output id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--text` | boolean |  | Print the content (Markdown with [S1 p.3] citations) instead of the record |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_studio_show`, served by `rbai mcp serve` by default.

```sh
rbai studio show <project id> <output id> -o json
rbai studio show <project id> <output id> --text > brief.md
```

<a id="cmd-studio-create"></a>

### rbai studio create

Make a Studio output from the project's sources (uses credits).

```text
rbai studio create [project] --kind <kind> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--kind <kind>` | string | required | The output kind, e.g. briefing, evidence_table, methods, rigor, agreements, timeline, presentation, custom (the server decides which exist) |
| `--sources <n>` | list (repeatable, or comma-separated) |  | Only these source numbers |
| `--options <json|@file>` | string |  | Kind-specific options as JSON: {"columns": […]}, {"custom": {…}} or {"presentation": {…}} |
| `--use-credits` | boolean |  | Pay with credits when the plan's allowance is used up |
| `-w, --wait` | boolean |  | Wait until it is ready |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_studio_create`, served by `rbai mcp serve` by default.

```sh
rbai studio create <project id> --kind evidence_table --sources 1,2,3 --wait
```

<a id="cmd-studio-retry"></a>

### rbai studio retry

Make a failed Studio output again.

```text
rbai studio retry <project> <note> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<note>` | yes | Output id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--use-credits` | boolean |  | Pay with credits when the allowance is used up |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: `rbai_studio_retry` with `rbai mcp serve --tools studio`.

```sh
rbai studio retry <project id> <output id>
```

<a id="cmd-studio-download"></a>

### rbai studio download

Download a presentation output as .pptx.

```text
rbai studio download <project> <note> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<note>` | yes | Output id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--version <n>` | number |  | A version (default: the current one) |
| `--dest <path>` | string |  | Where to write it (default: <id>.pptx) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_studio_download` with `rbai mcp serve --tools studio`.

```sh
rbai studio download <project id> <output id> --dest talk.pptx
```

<a id="cmd-studio-delete"></a>

### rbai studio delete

Delete a Studio output.

```text
rbai studio delete <project> <note>
```

Aliases: `rbai studio rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<project>` | yes | Project id |
| `<note>` | yes | Output id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_studio_delete` with `rbai mcp serve --tools studio` `--allow-destructive`.

```sh
rbai studio delete <project id> <output id> --yes
```

<a id="cmd-studio-templates"></a>

### rbai studio templates

Your saved custom outputs and the ready-made templates.

```text
rbai studio templates
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_studio_templates` with `rbai mcp serve --tools studio`.

```sh
rbai studio templates -o json
```

## rbai slides

Presentations: make, build with AI, download, upload, versions.

<a id="cmd-slides-list"></a>

### rbai slides list

Your presentations.

```text
rbai slides list
```

Aliases: `rbai slides ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_slides_list`, served by `rbai mcp serve` by default.

```sh
rbai slides list
```

<a id="cmd-slides-show"></a>

### rbai slides show

A presentation: its versions and the AI's last run (its steps and charge).

```text
rbai slides show <id>
```

Aliases: `rbai slides view`, `rbai slides get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_slides_show` with `rbai mcp serve --tools slides`.

```sh
rbai slides show <id>
rbai slides show <id> -o json
```

<a id="cmd-slides-create"></a>

### rbai slides create

Make a presentation; with a request, the AI builds it (uses credits and a presentation of your month's allowance).

```text
rbai slides create [request...] [flags]
```

Aliases: `rbai slides new`.

Without a request: a blank deck, as New presentation makes in the web app. With one, the AI builds the deck from it (--use-credits: when the month's presentations are used up, pay for this one with credits). --wait follows the AI's steps.

| Argument | Required | Description |
| --- | --- | --- |
| `[request...]` | no | What the presentation is about (optional) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--title <title>` | string |  | Its title |
| `--use-credits` | boolean |  | Pay with credits when the month's presentations are used up |
| `-w, --wait` | boolean |  | Follow the AI until the deck is built |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_slides_create` with `rbai mcp serve --tools slides`.

```sh
rbai slides create --title "Lab meeting 12 Nov"
rbai slides create "A 10-slide talk on CRISPR base editing in T cells" --wait
```

<a id="cmd-slides-edit"></a>

### rbai slides edit

Ask the AI to change a presentation (uses credits).

```text
rbai slides edit <id> <instruction...> [flags]
```

Aliases: `rbai slides ai`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |
| `<instruction...>` | yes | What to change |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--slide <n>` | number |  | The slide to change (as numbered in the deck) |
| `--use-credits` | boolean |  | A blank deck's first build: pay with credits when the month's presentations are used up |
| `-w, --wait` | boolean |  | Follow the AI's steps until it finishes |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_slides_edit` with `rbai mcp serve --tools slides`.

```sh
rbai slides edit <id> "Add a methods slide after slide 3" --wait
rbai slides edit <id> "Shorten the bullets" --slide 4
```

<a id="cmd-slides-stop"></a>

### rbai slides stop

Stop the AI working on a presentation.

```text
rbai slides stop <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_slides_stop` with `rbai mcp serve --tools slides`.

```sh
rbai slides stop <id>
```

<a id="cmd-slides-download"></a>

### rbai slides download

Download a presentation as .pptx (the current version, or --version).

```text
rbai slides download <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--version <n>` | number |  | A version (default: the current one) |
| `--dest <path>` | string |  | Where to write it (default: <id>.pptx; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_slides_download` with `rbai mcp serve --tools slides`.

```sh
rbai slides download <id> --dest talk.pptx
```

<a id="cmd-slides-upload"></a>

### rbai slides upload

Save a .pptx you edited (in PowerPoint) as the presentation's next version.

```text
rbai slides upload <id> <file> --from <version>
```

Aliases: `rbai slides save`.

--from is the version you downloaded; the server refuses (409) when a newer one exists, so nothing is silently undone. At most 4 MB.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |
| `<file>` | yes | The .pptx file |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--from <version>` | number | required | The version the file was downloaded from (`rbai slides show`) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_slides_upload` with `rbai mcp serve --tools slides`.

```sh
rbai slides upload <id> talk.pptx --from 3
```

<a id="cmd-slides-restore"></a>

### rbai slides restore

Make an earlier version the current one.

```text
rbai slides restore <id> <version>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |
| `<version>` | yes | Version number |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_slides_restore` with `rbai mcp serve --tools slides`.

```sh
rbai slides restore <id> 2
```

<a id="cmd-slides-rename"></a>

### rbai slides rename

Rename a presentation.

```text
rbai slides rename <id> <title...>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |
| `<title...>` | yes | The new title |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_slides_rename` with `rbai mcp serve --tools slides`.

```sh
rbai slides rename <id> "Lab meeting 12 Nov"
```

<a id="cmd-slides-delete"></a>

### rbai slides delete

Delete a presentation and its versions.

```text
rbai slides delete <id>
```

Aliases: `rbai slides rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Presentation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_slides_delete` with `rbai mcp serve --tools slides` `--allow-destructive`.

```sh
rbai slides delete <id> --yes
```

## rbai structure

Structure Studio: Edit with AI on a chat's 3D structure, its versions and files.

<a id="cmd-structure-show"></a>

### rbai structure show

A structure's studio: its versions, its Edit with AI turns and figures.

```text
rbai structure show <conversation> <anchor>
```

Aliases: `rbai structure view`, `rbai structure get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<conversation>` | yes | The chat's id (`rbai session list`) |
| `<anchor>` | yes | The tool call that showed the structure (show_structure's toolCallId) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_structure_show` with `rbai mcp serve --tools structure`.

```sh
rbai structure show <session id> <tool call id> -o json
```

<a id="cmd-structure-ask"></a>

### rbai structure ask

Edit with AI: ask Structure Studio to change, analyse or render a structure (uses credits).

```text
rbai structure ask <conversation> <anchor> <message...>
```

Aliases: `rbai structure edit`.

Streams the turn's Work log on stderr and its reply on stdout. Ctrl-C stops the turn on the server; a second Ctrl-C leaves at once. With -o json: {reply, status, versions, charged} at the end.

| Argument | Required | Description |
| --- | --- | --- |
| `<conversation>` | yes | The chat's id |
| `<anchor>` | yes | The tool call that showed the structure |
| `<message...>` | yes | What to do (at most 8,000 characters) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: `rbai_structure_ask` with `rbai mcp serve --tools structure`.

```sh
rbai structure ask <session id> <tool call id> "Mutate L54I in chain A and show clashes"
```

<a id="cmd-structure-download"></a>

### rbai structure download

Download a version of the structure (the file PyMOL saved).

```text
rbai structure download <conversation> <anchor> <version> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<conversation>` | yes | The chat's id |
| `<anchor>` | yes | The tool call that showed the structure |
| `<version>` | yes | Version number (`rbai structure show`) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: structure-v<n>.pdb; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_structure_download` with `rbai mcp serve --tools structure`.

```sh
rbai structure download <session id> <tool call id> 3 --dest mutant.pdb
```

## rbai file

Storage use and uploads.

<a id="cmd-file-list"></a>

### rbai file list

What uses your storage: the largest chats, PDFs and projects.

```text
rbai file list
```

Aliases: `rbai file ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_file_list`, served by `rbai mcp serve` by default.

```sh
rbai file list
rbai file list -o json
```

<a id="cmd-file-upload"></a>

### rbai file upload

Upload a file (up to 25 MB) and print its upload id.

```text
rbai file upload <path> [flags]
```

The id attaches the file to a chat turn or a project source (`rbai source add <project> --file <path>` uploads and adds in one step).

| Argument | Required | Description |
| --- | --- | --- |
| `<path>` | yes | Local file |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--for-project` | boolean |  | Store it as a project file (the web app's Projects → Files) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_file_upload` with `rbai mcp serve --tools file`.

```sh
rbai file upload data.csv
rbai file upload paper.pdf -o json --query uploadId
```

## rbai library

Your PDF library.

<a id="cmd-library-list"></a>

### rbai library list

List your library PDFs.

```text
rbai library list [flags]
```

Aliases: `rbai library ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--page <n>` | number | `1` | Page number |
| `-L, --limit <n>` | number | `20` | Per page (at most 100) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_library_list`, served by `rbai mcp serve` by default.

```sh
rbai library list
```

<a id="cmd-library-download"></a>

### rbai library download

Download a library PDF.

```text
rbai library download <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Document id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: its file name; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_library_download` with `rbai mcp serve --tools library`.

```sh
rbai library download <id>
rbai library download <id> --dest paper.pdf
```

<a id="cmd-library-delete"></a>

### rbai library delete

Delete a library PDF.

```text
rbai library delete <id>
```

Aliases: `rbai library rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Document id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_library_delete` with `rbai mcp serve --tools library` `--allow-destructive`.

```sh
rbai library delete <id> --yes
```

## rbai job

Long-running jobs on the server: list, watch, cancel, download outputs.

<a id="cmd-job-list"></a>

### rbai job list

List jobs, newest first.

```text
rbai job list [flags]
```

Aliases: `rbai job ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--status <status>` | string |  | Only jobs in this status (running, completed, failed, cancelled, …) |
| `-L, --limit <n>` | number | `50` | At most this many (server maximum 200) |
| `--offset <n>` | number | `0` | Skip this many |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_job_list`, served by `rbai mcp serve` by default.

```sh
rbai job list
rbai job list --status running -o json
```

<a id="cmd-job-show"></a>

### rbai job show

Show a job with its result.

```text
rbai job show <id>
```

Aliases: `rbai job view`, `rbai job get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_job_show`, served by `rbai mcp serve` by default.

```sh
rbai job show <id>
rbai job show <id> -o json --query job.result
```

<a id="cmd-job-watch"></a>

### rbai job watch

Wait for a job to finish, with progress on stderr.

```text
rbai job watch <id> [flags]
```

Aliases: `rbai job wait`.

Polls every 5 s, as the web app does. Exit 0 when it completed, 1 when it failed or was cancelled.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--max-wait <seconds>` | number | `0` | Give up after this long (0 = no limit) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai job watch <id>
rbai job watch <id> --max-wait 600
```

<a id="cmd-job-cancel"></a>

### rbai job cancel

Cancel a running job.

```text
rbai job cancel <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_job_cancel`, served by `rbai mcp serve` by default.

```sh
rbai job cancel <id>
```

<a id="cmd-job-delete"></a>

### rbai job delete

Delete a finished job.

```text
rbai job delete <id>
```

Aliases: `rbai job rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_job_delete` with `rbai mcp serve --tools job` `--allow-destructive`.

```sh
rbai job delete <id> --yes
```

<a id="cmd-job-pause"></a>

### rbai job pause

Pause a background job in a chat's sandbox.

```text
rbai job pause <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_job_pause` with `rbai mcp serve --tools job`.

```sh
rbai job pause <id>
```

<a id="cmd-job-resume"></a>

### rbai job resume

Resume a paused background job.

```text
rbai job resume <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_job_resume` with `rbai mcp serve --tools job`.

```sh
rbai job resume <id>
```

<a id="cmd-job-download"></a>

### rbai job download

Download an output file of a finished background job.

```text
rbai job download <id> <index> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Job id |
| `<index>` | yes | Output index (see `rbai job show <id>`) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: the output's file name; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_job_download` with `rbai mcp serve --tools job`.

```sh
rbai job download <id> 0
rbai job download <id> 2 --dest results.csv
```

## rbai figure

Figures and graphical abstracts: draw, edit, export.

<a id="cmd-figure-list"></a>

### rbai figure list

List your figures and this month's allowance.

```text
rbai figure list [flags]
```

Aliases: `rbai figure ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--source-type <value>` | string: review, project, page |  | Only figures of this kind of source |
| `--source <id>` | string |  | Only figures of this source id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_figure_list`, served by `rbai mcp serve` by default.

```sh
rbai figure list
rbai figure list --source-type review --source <review id>
```

<a id="cmd-figure-show"></a>

### rbai figure show

Show a figure (or one version with --version).

```text
rbai figure show <id> [flags]
```

Aliases: `rbai figure view`, `rbai figure get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--version <n>` | number |  | A version number |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_figure_show`, served by `rbai mcp serve` by default.

```sh
rbai figure show <id>
rbai figure show <id> --version 2 -o json
```

<a id="cmd-figure-create"></a>

### rbai figure create

Draw a figure from a review, a project or a page (uses the month's drawings or credits).

```text
rbai figure create --source-type <value> --source <id> --preset <preset> [flags]
```

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--source-type <value>` | string: review, project, page | required | What to summarise |
| `--source <id>` | string | required | Its id (review id, project id or page id) |
| `--preset <preset>` | string | required | The format, e.g. nature, cell, elsevier, acs, wiley, slide, poster, social (the server decides which exist) |
| `--sources <n>` | list (repeatable, or comma-separated) |  | Only these source numbers of a project |
| `--use-credits` | boolean |  | Pay with credits when this month's drawings are used up |
| `-w, --wait` | boolean |  | Wait until the drawing is ready |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_figure_create`, served by `rbai mcp serve` by default.

```sh
rbai figure create --source-type review --source <review id> --preset nature --wait
```

<a id="cmd-figure-edit"></a>

### rbai figure edit

Ask for a change: draws a new version (uses the month's drawings or credits).

```text
rbai figure edit <id> <instruction...> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |
| `<instruction...>` | yes | What to change |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--base <n>` | number |  | The version to start from (default: the current one) |
| `--use-credits` | boolean |  | Pay with credits when this month's drawings are used up |
| `-w, --wait` | boolean |  | Wait until the drawing is ready |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_figure_edit` with `rbai mcp serve --tools figure`.

```sh
rbai figure edit <id> "Use a lighter background and larger labels" --wait
```

<a id="cmd-figure-retry"></a>

### rbai figure retry

Draw a failed figure again.

```text
rbai figure retry <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--use-credits` | boolean |  | Pay with credits when this month's drawings are used up |
| `-w, --wait` | boolean |  | Wait until the drawing is ready |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_figure_retry` with `rbai mcp serve --tools figure`.

```sh
rbai figure retry <id> --wait
```

<a id="cmd-figure-restore"></a>

### rbai figure restore

Make an earlier version the current one.

```text
rbai figure restore <id> <version>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |
| `<version>` | yes | Version number |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_figure_restore` with `rbai mcp serve --tools figure`.

```sh
rbai figure restore <id> 2
```

<a id="cmd-figure-export"></a>

### rbai figure export

Download a figure version as PNG or PDF.

```text
rbai figure export <id> [flags]
```

Aliases: `rbai figure download`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--format <value>` | string: png, pdf | `png` | File format |
| `--version <n>` | number |  | Version (default: the current one) |
| `--dest <path>` | string |  | Where to write it (default: <id>-v<n>.<format>; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_figure_export` with `rbai mcp serve --tools figure`.

```sh
rbai figure export <id> --format pdf
rbai figure export <id> --version 1 --dest abstract.png
```

<a id="cmd-figure-add-to-page"></a>

### rbai figure add-to-page

Add a figure version to a Report Writer page.

```text
rbai figure add-to-page <id> <page> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |
| `<page>` | yes | Page (manuscript) id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--version <n>` | number |  | Version (default: the current one) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_figure_add_to_page` with `rbai mcp serve --tools figure`.

```sh
rbai figure add-to-page <id> <page id>
```

<a id="cmd-figure-delete"></a>

### rbai figure delete

Delete a figure and all its versions.

```text
rbai figure delete <id>
```

Aliases: `rbai figure rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Figure id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_figure_delete` with `rbai mcp serve --tools figure` `--allow-destructive`.

```sh
rbai figure delete <id> --yes
```

## rbai plot

Edit a chat's Python figure with AI (Edit with AI), with the model's thinking as it works.

<a id="cmd-plot-edit"></a>

### rbai plot edit

Change a chat's figure with AI: the model rewrites its program, the sandbox runs it, the model checks the figure, and it is saved (uses credits).

```text
rbai plot edit <request...> [flags]
```

The figure is the newest one an answer of the chat drew (in Python, or with a script in R or another language), the one --figure names, or the program in --code. The model rewrites the program in its own language; it runs in the chat's code sandbox, beside the chat's files; a program that fails goes back to the model with its error until it draws the figure; then the model looks at the figure, corrects what it sees wrong, and says what the figure shows. It checks only what is visible, not the data behind it. The new figure is saved here under its "-edit" name, with its program beside it (.py, or the script with a .figure.json record), so the next edit can start from it with --code. The model's thinking shows while it works, with no time limit: an edit stops only when nothing, not even the server's heartbeat, arrives for 60 s. Ctrl-C stops the edit on the server too.

| Argument | Required | Description |
| --- | --- | --- |
| `<request...>` | yes | What to change |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--session <id>` | string |  | The chat whose figure to edit (`rbai session list`); with --code, the chat whose sandbox runs it |
| `--figure <file name>` | string |  | The figure's file name in the chat (default: the newest figure) |
| `--code <file>` | string |  | Edit this program instead: an earlier edit's .py, or the .figure.json of an edit of a script figure |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this edit (default: the one saved in your account) |
| `--dest <path>` | string |  | Where to write the new figure (default: its file name here; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- `-o json`: {sessionId, figure, request, code, reply, cannot, image: {file, name, bytes, link}, codeFile, sourceFile, check: {status, looks, note}, calls, tries, usage: {creditTokens, credits, …}}.
- MCP: not an MCP tool.

```sh
rbai plot edit --session <chat id> "Use a log scale on the y-axis and colour lung red"
rbai plot edit --session <chat id> --figure ace2_tpm_boxplot.png "Larger axis labels" --effort low
rbai plot edit --session <chat id> --code ace2_tpm_boxplot-edit.py "Remove the top and right spines"   # Start from an earlier edit
```

## rbai manuscript

Report Writer pages: list, read, append, share, history.

<a id="cmd-manuscript-list"></a>

### rbai manuscript list

List your Report Writer pages (owned and shared with you).

```text
rbai manuscript list
```

Aliases: `rbai manuscript ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_manuscript_list`, served by `rbai mcp serve` by default.

```sh
rbai manuscript list
```

<a id="cmd-manuscript-show"></a>

### rbai manuscript show

Show a page (with --doc: its document as ProseMirror JSON).

```text
rbai manuscript show <id> [flags]
```

Aliases: `rbai manuscript view`, `rbai manuscript get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--doc` | boolean |  | The live document instead of the page record |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_manuscript_show`, served by `rbai mcp serve` by default.

```sh
rbai manuscript show <id>
rbai manuscript show <id> --doc -o json > page.json
```

<a id="cmd-manuscript-append"></a>

### rbai manuscript append

Append Markdown to the end of a page.

```text
rbai manuscript append <id> -m, --markdown <text|@file|->
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-m, --markdown <text|@file|->` | string | required | The Markdown (at most 500,000 characters; @file reads a file, - reads stdin) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_manuscript_append`, served by `rbai mcp serve` by default.

```sh
rbai manuscript append <id> -m @results.md
rbai review export <rid> | rbai manuscript append <id> -m -
```

<a id="cmd-manuscript-export"></a>

### rbai manuscript export

Save a page's document (ProseMirror JSON) to a file.

```text
rbai manuscript export <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | File to write (default: stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_manuscript_export` with `rbai mcp serve --tools manuscript`.

```sh
rbai manuscript export <id> --dest page.json
```

<a id="cmd-manuscript-delete"></a>

### rbai manuscript delete

Delete a page you own (with its images).

```text
rbai manuscript delete <id>
```

Aliases: `rbai manuscript rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_manuscript_delete` with `rbai mcp serve --tools manuscript` `--allow-destructive`.

```sh
rbai manuscript delete <id> --yes
```

<a id="cmd-manuscript-history"></a>

### rbai manuscript history

A page's saved checkpoints (or one with --checkpoint).

```text
rbai manuscript history <id> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--checkpoint <id>` | string |  | One checkpoint |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_manuscript_history` with `rbai mcp serve --tools manuscript`.

```sh
rbai manuscript history <id>
rbai manuscript history <id> --checkpoint <cid> -o json
```

<a id="cmd-manuscript-open"></a>

### rbai manuscript open

Open the Report Writer in the web app (prints the URL without a terminal).

```text
rbai manuscript open
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai manuscript open
```

<a id="cmd-manuscript-member-list"></a>

### rbai manuscript member list

Who can open a page.

```text
rbai manuscript member list <id>
```

Aliases: `rbai manuscript member ls`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_manuscript_member_list` with `rbai mcp serve --tools manuscript`.

```sh
rbai manuscript member list <id>
```

<a id="cmd-manuscript-member-add"></a>

### rbai manuscript member add

Share a page with an RBAi account.

```text
rbai manuscript member add <id> <email> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |
| `<email>` | yes | Email of their RBAi account |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--role <value>` | string: editor, viewer | `viewer` | What they may do |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_manuscript_member_add` with `rbai mcp serve --tools manuscript`.

```sh
rbai manuscript member add <id> colleague@example.org --role editor
```

<a id="cmd-manuscript-member-update"></a>

### rbai manuscript member update

Change a member's role.

```text
rbai manuscript member update <id> <user> --role <value>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |
| `<user>` | yes | Their user id (see member list) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--role <value>` | string: editor, viewer | required | The new role |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_manuscript_member_update` with `rbai mcp serve --tools manuscript`.

```sh
rbai manuscript member update <id> <user id> --role editor
```

<a id="cmd-manuscript-member-remove"></a>

### rbai manuscript member remove

Remove a member from a page.

```text
rbai manuscript member remove <id> <user>
```

Aliases: `rbai manuscript member rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Page id |
| `<user>` | yes | Their user id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_manuscript_member_remove` with `rbai mcp serve --tools manuscript` `--allow-destructive`.

```sh
rbai manuscript member remove <id> <user id> --yes
```

## rbai coauthor

The co-author agent that writes in Report Writer pages.

<a id="cmd-coauthor-ask"></a>

### rbai coauthor ask

Ask the co-author to write in a page (uses credits).

```text
rbai coauthor ask <manuscript> <prompt...> [flags]
```

Aliases: `rbai coauthor create`.

The page must have been opened in the editor once (the server answers 409 otherwise).

| Argument | Required | Description |
| --- | --- | --- |
| `<manuscript>` | yes | Page id |
| `<prompt...>` | yes | What to write or change |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--mode <mode>` | string: auto, edit, suggest |  | auto (default: edits while the page is open, suggests while you are away), edit (changes the page directly) or suggest (tracked suggestions you accept or reject in the editor) |
| `-w, --wait` | boolean |  | Wait until the task finishes |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- Long work: returns at once; `--wait` blocks until it finishes (exit 1 when it ends failed or cancelled).
- MCP: `rbai_coauthor_ask`, served by `rbai mcp serve` by default.

```sh
rbai coauthor ask <page id> "Tighten the Discussion to 400 words" --wait
rbai coauthor ask <page id> "Suggest a clearer Methods paragraph" --mode suggest   # Tracked suggestions to accept in the editor
```

<a id="cmd-coauthor-list"></a>

### rbai coauthor list

Your co-author tasks on a page (newest 30).

```text
rbai coauthor list <manuscript>
```

Aliases: `rbai coauthor ls`.

| Argument | Required | Description |
| --- | --- | --- |
| `<manuscript>` | yes | Page id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_coauthor_list` with `rbai mcp serve --tools coauthor`.

```sh
rbai coauthor list <page id>
```

<a id="cmd-coauthor-show"></a>

### rbai coauthor show

Show a co-author task.

```text
rbai coauthor show <id>
```

Aliases: `rbai coauthor view`, `rbai coauthor get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Task id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_coauthor_show`, served by `rbai mcp serve` by default.

```sh
rbai coauthor show <task id>
```

<a id="cmd-coauthor-cancel"></a>

### rbai coauthor cancel

Stop a co-author task.

```text
rbai coauthor cancel <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Task id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_coauthor_cancel` with `rbai mcp serve --tools coauthor`.

```sh
rbai coauthor cancel <task id>
```

## rbai galaxy

The Galaxy agent, your Galaxy key, histories, datasets and tracked jobs.

<a id="cmd-galaxy-ask"></a>

### rbai galaxy ask

Give the Galaxy agent a task; live steps on stderr, the answer on stdout (uses credits).

```text
rbai galaxy ask [prompt...] [flags]
```

Aliases: `rbai galaxy run`.

One turn of the Galaxy specialist (the web app's Galaxy Lab), stored as a Galaxy conversation: a new one unless --session or --continue names one. Steps and tool calls stream to stderr (-q hides them); the answer, exactly as the agent wrote it, goes to stdout. It uses GALAXY_API_KEY when set, else the Galaxy key saved with `rbai galaxy key set`. Same output formats and exit codes as `rbai ask` (--output-format text|json|stream-json; 8 when the agent asked a question nobody could answer).

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | The task (or - for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--output-format <format>` | string: text, json, stream-json |  | text (the answer only, default), json (one object at the end) or stream-json (NDJSON events as they stream) |
| `--session <id>` | string |  | Continue this conversation (`rbai session list` shows them) |
| `-c, --continue` | boolean |  | Continue the most recent conversation |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |
| `--galaxy-server <url>` | string |  | Galaxy server URL (default: GALAXY_SERVER_URL, else your active Galaxy server, `rbai galaxy key list`) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- `-o json`: as rbai ask: --output-format json or stream-json.
- MCP: not an MCP tool.

```sh
rbai galaxy ask "Run FastQC on the two FASTQ files in my newest history"
rbai galaxy ask "List my Galaxy histories" --galaxy-server https://usegalaxy.org > answer.md
rbai galaxy ask --continue "Now run MultiQC on those reports" --output-format stream-json
```

<a id="cmd-galaxy-chat"></a>

### rbai galaxy chat

Chat with the Galaxy agent in the terminal (uses credits).

```text
rbai galaxy chat [prompt...] [flags]
```

The full-screen chat (`rbai chat`) with the Galaxy specialist; the conversation is listed in the web app's Galaxy Lab.

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | A first message, sent as soon as the chat opens |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--session <id>` | string |  | Continue this conversation (`rbai session list` shows them) |
| `-c, --continue` | boolean |  | Continue the most recent conversation |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |
| `--galaxy-server <url>` | string |  | Galaxy server URL (default: GALAXY_SERVER_URL, else your active Galaxy server, `rbai galaxy key list`) |
| `--plain` | boolean |  | A plain line-based chat with no redrawing (screen readers, dumb terminals) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: not an MCP tool.

```sh
rbai galaxy chat
rbai galaxy chat --continue
```

<a id="cmd-galaxy-jobs"></a>

### rbai galaxy jobs

Galaxy jobs RBAi is tracking for you.

```text
rbai galaxy jobs [id]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[id]` | no | One job (its Galaxy job id) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_jobs`, served by `rbai mcp serve` by default.

```sh
rbai galaxy jobs
rbai galaxy jobs <galaxy job id> -o json
```

<a id="cmd-galaxy-histories"></a>

### rbai galaxy histories

Your Galaxy histories (GALAXY_API_KEY, else the saved key).

```text
rbai galaxy histories
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_histories` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy histories
```

<a id="cmd-galaxy-datasets"></a>

### rbai galaxy datasets

The datasets of a Galaxy history (GALAXY_API_KEY, else the saved key).

```text
rbai galaxy datasets <history>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<history>` | yes | History id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_datasets` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy datasets <history id>
```

<a id="cmd-galaxy-download"></a>

### rbai galaxy download

Download a Galaxy dataset (GALAXY_API_KEY, else the saved key).

```text
rbai galaxy download <history> <dataset> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<history>` | yes | History id |
| `<dataset>` | yes | Dataset id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--dest <path>` | string |  | Where to write it (default: <dataset id>; - for stdout) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_download` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy download <history id> <dataset id> --dest reads.fastqsanger
```

<a id="cmd-galaxy-workflows"></a>

### rbai galaxy workflows

Search RBAi's curated Galaxy workflows (GALAXY_API_KEY, else the saved key).

```text
rbai galaxy workflows [query...] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[query...]` | no | What the workflow should do |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--top <n>` | number | `8` | How many |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_workflows` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy workflows rna-seq differential expression
```

<a id="cmd-galaxy-test"></a>

### rbai galaxy test

Check your Galaxy key against Galaxy (GALAXY_API_KEY, else the saved key).

```text
rbai galaxy test
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_test` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy test   # The key saved with `rbai galaxy key set`
GALAXY_API_KEY=… rbai galaxy test   # Another key, for this run only
```

<a id="cmd-galaxy-key-set"></a>

### rbai galaxy key set

Save your Galaxy API key for a server in your RBAi account (encrypted) for the agent and job tracking.

```text
rbai galaxy key set [flags]
```

The key is read from a masked prompt, from stdin with --with-key, or from GALAXY_API_KEY. The server becomes your active Galaxy server.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--with-key` | boolean |  | Read the key from stdin |
| `--server <url>` | string |  | The Galaxy server (default: your active one; `rbai galaxy key list` shows them) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai galaxy key set
rbai galaxy key set --server https://usegalaxy.org --with-key < galaxy-key.txt
```

<a id="cmd-galaxy-key-list"></a>

### rbai galaxy key list

Your Galaxy servers with a saved key (previews, never a key) and the active one.

```text
rbai galaxy key list
```

Aliases: `rbai galaxy key ls`, `rbai galaxy key show`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_galaxy_key_list` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy key list
rbai galaxy key list -o json
```

<a id="cmd-galaxy-key-use"></a>

### rbai galaxy key use

Make a saved Galaxy server your active one (new Galaxy work and tracking use it).

```text
rbai galaxy key use <server>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<server>` | yes | The server's URL, as `rbai galaxy key list` shows it |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_galaxy_key_use` with `rbai mcp serve --tools galaxy`.

```sh
rbai galaxy key use https://usegalaxy.org
```

<a id="cmd-galaxy-key-delete"></a>

### rbai galaxy key delete

Remove the saved Galaxy key of a server (default: the active one).

```text
rbai galaxy key delete [flags]
```

Aliases: `rbai galaxy key rm`.

Removing the active server's key leaves no server active until you choose one (`rbai galaxy key use`).

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--server <url>` | string |  | The Galaxy server (default: your active one; `rbai galaxy key list` shows them) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_galaxy_key_delete` with `rbai mcp serve --tools galaxy` `--allow-destructive`.

```sh
rbai galaxy key delete --yes
rbai galaxy key delete --server https://usegalaxy.org --yes
```

## rbai connect

RBAi in Connect: find materials, services, collaborators and papers; draft emails.

<a id="cmd-connect-ask"></a>

### rbai connect ask

Ask RBAi in Connect (materials, services, collaborators, papers) and print the answer (uses credits).

```text
rbai connect ask [prompt...] [flags]
```

One turn of your Connect conversation with RBAi, for scripts and agents, with the output formats of `rbai ask`. RBAi searches methods sections, registries and listings, and can draft an email; it never sends one. Send a draft from the web app (Connect → RBAi), after reading it.

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | The request (or - for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--output-format <format>` | string: text, json, stream-json |  | text (the answer only, default), json (one object at the end) or stream-json (NDJSON events as they stream) |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- `-o json`: as rbai ask: --output-format json or stream-json.
- MCP: not an MCP tool.

```sh
rbai connect ask "Who distributes a validated anti-GPX4 antibody for mouse tissue?"
rbai connect ask "Find a core facility in Germany that runs cryo-EM for outside users" -o json
```

<a id="cmd-connect-chat"></a>

### rbai connect chat

Chat with RBAi in Connect in the terminal (the full-screen chat).

```text
rbai connect chat [prompt...] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[prompt...]` | no | A first message, sent as soon as the chat opens |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this run (default: the one saved in your account) |
| `--plain` | boolean |  | A plain line-based chat with no redrawing (screen readers, dumb terminals) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- MCP: not an MCP tool.

```sh
rbai connect chat
```

<a id="cmd-connect-show"></a>

### rbai connect show

The latest messages of your Connect conversation with RBAi.

```text
rbai connect show
```

Aliases: `rbai connect view`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_connect_show` with `rbai mcp serve --tools connect`.

```sh
rbai connect show
rbai connect show -o json
```

<a id="cmd-connect-delete"></a>

### rbai connect delete

Delete one message of your Connect conversation with RBAi (later turns no longer read it).

```text
rbai connect delete <message>
```

Aliases: `rbai connect rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<message>` | yes | Message id (`rbai connect show`) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_connect_delete` with `rbai mcp serve --tools connect` `--allow-destructive`.

```sh
rbai connect delete <message id> --yes
```

<a id="cmd-connect-clear"></a>

### rbai connect clear

Clear your Connect conversation with RBAi (every message; sent emails stay).

```text
rbai connect clear
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_connect_clear` with `rbai mcp serve --tools connect` `--allow-destructive`.

```sh
rbai connect clear --yes
```

## rbai message

Messages with other members (Connect).

<a id="cmd-message-list"></a>

### rbai message list

Your conversations with other members.

```text
rbai message list
```

Aliases: `rbai message ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_message_list` with `rbai mcp serve --tools message`.

```sh
rbai message list
```

<a id="cmd-message-show"></a>

### rbai message show

The messages of a conversation.

```text
rbai message show <id>
```

Aliases: `rbai message read`, `rbai message view`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Conversation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_message_show` with `rbai mcp serve --tools message`.

```sh
rbai message show <id>
```

<a id="cmd-message-send"></a>

### rbai message send

Send a message in a conversation, or to a member by handle.

```text
rbai message send <to> -b, --body <text|@file|->
```

| Argument | Required | Description |
| --- | --- | --- |
| `<to>` | yes | Conversation id, or @handle of a member |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-b, --body <text|@file|->` | string | required | The message |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_message_send` with `rbai mcp serve --tools message`.

```sh
rbai message send <conversation id> -b "Thanks, sending the plasmid map today."
rbai message send @jdoe -b @note.txt
```

<a id="cmd-message-unread"></a>

### rbai message unread

Unread message counts.

```text
rbai message unread
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_message_unread` with `rbai mcp serve --tools message`.

```sh
rbai message unread -o json
```

<a id="cmd-message-mark-read"></a>

### rbai message mark-read

Mark a conversation read.

```text
rbai message mark-read <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Conversation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_message_mark_read` with `rbai mcp serve --tools message`.

```sh
rbai message mark-read <id>
```

<a id="cmd-message-archive"></a>

### rbai message archive

Archive a conversation.

```text
rbai message archive <id>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Conversation id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_message_archive` with `rbai mcp serve --tools message`.

```sh
rbai message archive <id>
```

## rbai request

Research requests and your lab services.

<a id="cmd-request-list"></a>

### rbai request list

Your research requests (My requests).

```text
rbai request list
```

Aliases: `rbai request ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_request_list` with `rbai mcp serve --tools request`.

```sh
rbai request list
```

<a id="cmd-request-show"></a>

### rbai request show

The email RBAi sent for a request (via rbai_email), with its replies.

```text
rbai request show <id>
```

Aliases: `rbai request view`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Request id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_request_show` with `rbai mcp serve --tools request`.

```sh
rbai request show <id>
```

<a id="cmd-request-update"></a>

### rbai request update

Set the status of a request you sent from your own email (sent, replied, received, closed).

```text
rbai request update <id> <status>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Request id |
| `<status>` | yes | sent, replied, received or closed (services/researchRequests.js EMAIL_STATUSES) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_request_update` with `rbai mcp serve --tools request`.

```sh
rbai request update <id> replied
```

<a id="cmd-request-delete"></a>

### rbai request delete

Delete a request from My requests.

```text
rbai request delete <id>
```

Aliases: `rbai request rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Request id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_request_delete` with `rbai mcp serve --tools request` `--allow-destructive`.

```sh
rbai request delete <id> --yes
```

<a id="cmd-request-services"></a>

### rbai request services

Your lab services and the kinds of requests you accept.

```text
rbai request services
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_request_services` with `rbai mcp serve --tools request`.

```sh
rbai request services -o json
```

## rbai researcher

Find researchers and labs.

<a id="cmd-researcher-search"></a>

### rbai researcher search

Find researchers working on a topic.

```text
rbai researcher search <topic...>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<topic...>` | yes | Topic (2-120 characters) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_researcher_search`, served by `rbai mcp serve` by default.

```sh
rbai researcher search CRISPR base editing
```

<a id="cmd-researcher-labs"></a>

### rbai researcher labs

Find labs that used a reagent or method, with the sentence of their paper that shows it, through RBAi in Connect (uses credits).

```text
rbai researcher labs <query...> [flags]
```

Sends one message to RBAi in Connect, as `rbai connect ask` does, and shows its lab search as the web's Connect shows it. RBAi writes the item's other names (spellings, product and catalogue names, repository ids), searches the Methods of papers in Europe PMC for all of them, and reads every lab's newest open-access paper, in rank order: its acknowledgments and Methods, and the rest of it when those do not settle it. Each lab shows the sentence that shows its use, checked word for word against the paper, or why there is none. It first says how many papers match and what reading every lab would cost, reads until --budget credits (40 by default), and then asks whether to read on (y/N here; y goes on in the same conversation). Ctrl-C is Connect's Stop; --resume goes on with the search of the same item and country where it stopped, and a lab already read costs nothing again. The search keeps running on the server if this terminal closes; `rbai connect show` prints RBAi's answer.

| Argument | Required | Description |
| --- | --- | --- |
| `<query...>` | yes | The reagent, cell line, antibody, RRID or method |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--country <code>` | string |  | Two-letter country code (or a country's name) |
| `--budget <credits>` | number |  | Credits RBAi may read for before it asks to read on (default 40) |
| `--resume` | boolean |  | Go on with the search of this item and country where it stopped (its budget, a Stop or your credits) |
| `--papers` | boolean |  | One row a paper instead of one a lab |
| `--effort <level>` | string: low, medium, high, max |  | Thinking effort for this search (default: the one saved in your account) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: **spends credits** (or the month's allowance, then credits).
- `-o json`: {status, message, searchId, item, country, counts: {known, read, withSentence, pending}, ask, cost, labs: [{index, name, affiliation, status, sentence, section, why, paper: {pmcid, doi, url, year}, contact}], answer, sessionId, url, credits}.
- MCP: not an MCP tool.

```sh
rbai researcher labs "pLKO.1" --country US
rbai researcher labs "MISSION shRNA" --country IS --effort medium -o json
rbai researcher labs "pLKO.1" --country US --resume --budget 80   # Go on where the search stopped
```

## rbai skill

Skills: expert procedures the assistant follows.

<a id="cmd-skill-list"></a>

### rbai skill list

Skills the assistant can use (with --mine: the ones you wrote).

```text
rbai skill list [flags]
```

Aliases: `rbai skill ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--mine` | boolean |  | Only your own skills |
| `--all` | boolean |  | Include skills that are not approved to run |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_skill_list`, served by `rbai mcp serve` by default.

```sh
rbai skill list
rbai skill list --mine -o json
```

<a id="cmd-skill-show"></a>

### rbai skill show

One skill.

```text
rbai skill show <id>
```

Aliases: `rbai skill view`, `rbai skill get`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Skill id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_skill_show` with `rbai mcp serve --tools skill`.

```sh
rbai skill show phylogenetics-sandbox
```

<a id="cmd-skill-create"></a>

### rbai skill create

Add your own skill from a SKILL.md file.

```text
rbai skill create <file> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<file>` | yes | The SKILL.md (- for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--reference <file>` | list (repeatable, or comma-separated) |  | A reference file the skill uses |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_skill_create` with `rbai mcp serve --tools skill`.

```sh
rbai skill create SKILL.md --reference protocol.md
```

<a id="cmd-skill-update"></a>

### rbai skill update

Replace your skill's SKILL.md.

```text
rbai skill update <id> <file> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Skill id |
| `<file>` | yes | The SKILL.md (- for stdin) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--reference <file>` | list (repeatable, or comma-separated) |  | A reference file the skill uses |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_skill_update` with `rbai mcp serve --tools skill`.

```sh
rbai skill update <id> SKILL.md
```

<a id="cmd-skill-delete"></a>

### rbai skill delete

Delete your skill.

```text
rbai skill delete <id>
```

Aliases: `rbai skill rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Skill id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_skill_delete` with `rbai mcp serve --tools skill` `--allow-destructive`.

```sh
rbai skill delete <id> --yes
```

<a id="cmd-skill-preview"></a>

### rbai skill preview

Which skills a question would activate (runs nothing).

```text
rbai skill preview <question...> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<question...>` | yes | The question |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--limit <n>` | number |  | At most this many skills |
| `--force <id>` | list (repeatable, or comma-separated) |  | Skill ids to force |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_skill_preview` with `rbai mcp serve --tools skill`.

```sh
rbai skill preview "build a phylogenetic tree of these sequences"
```

## rbai tool

Biomedical tools and database schemas: list, search, run.

<a id="cmd-tool-list"></a>

### rbai tool list

The biomedical tools (MCP) the assistant can call.

```text
rbai tool list [flags]
```

Aliases: `rbai tool ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--server <name>` | string |  | Only this server's tools |
| `--external` | boolean |  | Tools of your connected MCP servers instead |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_tool_list` with `rbai mcp serve --tools tool`.

```sh
rbai tool list
rbai tool list --server uniprot-server -o json
```

<a id="cmd-tool-search"></a>

### rbai tool search

Find tools and database schemas for a question.

```text
rbai tool search <query...> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<query...>` | yes | What you want to do |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--top <n>` | number | `10` | How many |
| `--target <target>` | list (repeatable, or comma-separated) |  | Restrict to these targets (e.g. Databases/UniProt) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_tool_search`, served by `rbai mcp serve` by default.

```sh
rbai tool search "protein structure of TP53"
```

<a id="cmd-tool-show"></a>

### rbai tool show

One tool with its input schema.

```text
rbai tool show <name>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Tool name |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_tool_show` with `rbai mcp serve --tools tool`.

```sh
rbai tool show uniprot_search
```

<a id="cmd-tool-run"></a>

### rbai tool run

Run one tool with JSON arguments.

```text
rbai tool run <name> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Tool name (see `rbai tool list`) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-a, --args <json|@file|->` | string | `{}` | The tool's arguments as a JSON object |
| `--chat <id>` | string |  | The chat whose code sandbox the call uses |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_tool_run`, served by `rbai mcp serve` by default.

```sh
rbai tool run uniprot_search -a '{"query":"TP53 human"}'
rbai tool run blast -a @query.json -o json
```

<a id="cmd-tool-schemas"></a>

### rbai tool schemas

The API databases the chat can read through api_describe and api_call.

```text
rbai tool schemas
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_tool_schemas` with `rbai mcp serve --tools tool`.

```sh
rbai tool schemas
rbai tool schemas -o json
```

## rbai connection

External MCP servers the assistant can use (Settings → Connectors).

<a id="cmd-connection-list"></a>

### rbai connection list

Your connected MCP servers.

```text
rbai connection list
```

Aliases: `rbai connection ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_connection_list` with `rbai mcp serve --tools connection`.

```sh
rbai connection list
```

<a id="cmd-connection-add"></a>

### rbai connection add

Connect an MCP server (Streamable HTTP) for the assistant to use.

```text
rbai connection add <name> <url> [flags]
```

Aliases: `rbai connection connect`.

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | A short name |
| `<url>` | yes | The server URL |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--headers-file <file>` | string |  | JSON object of auth headers, from a file (kept off the command line) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_connection_add` with `rbai mcp serve --tools connection`.

```sh
rbai connection add mylab https://mcp.example.org/mcp --headers-file headers.json
```

<a id="cmd-connection-remove"></a>

### rbai connection remove

Disconnect an MCP server.

```text
rbai connection remove <name>
```

Aliases: `rbai connection rm`, `rbai connection disconnect`.

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Server name |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_connection_remove` with `rbai mcp serve --tools connection` `--allow-destructive`.

```sh
rbai connection remove mylab
```

<a id="cmd-connection-reconnect"></a>

### rbai connection reconnect

Reconnect an MCP server.

```text
rbai connection reconnect <name>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Server name |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_connection_reconnect` with `rbai mcp serve --tools connection`.

```sh
rbai connection reconnect mylab
```

<a id="cmd-connection-health"></a>

### rbai connection health

Check an MCP server.

```text
rbai connection health <name>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Server name |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_connection_health` with `rbai mcp serve --tools connection`.

```sh
rbai connection health mylab
```

## rbai model

The model your work runs on (Settings → Model & approvals).

<a id="cmd-model-list"></a>

### rbai model list

The model your work runs on, the ones you may choose, and each command's model.

```text
rbai model list
```

Aliases: `rbai model ls`, `rbai model show`.

The server picks the model of every answer: the app's model, or the one you chose in Settings → Model & approvals among the models your plan includes. The table says which plans include each model and whether yours does. With -o json or yaml: {model, choices, available, plans, mayChoose, surfaces}: available, the models your plan may choose; plans, the plans that include each other model; surfaces, the model each part of the app runs on for you.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_model_list`, served by `rbai mcp serve` by default.

```sh
rbai model list
rbai model list -o json --query surfaces.chat   # The model rbai ask and rbai chat run on for you
```

<a id="cmd-model-set"></a>

### rbai model set

Choose the model your work runs on, among the ones your plan includes (Settings → Model & approvals).

```text
rbai model set <id>
```

Aliases: `rbai model use`.

Saved to your account: the chat, Literature Reviews, the Report Writer, Connect and Studio run on it, in the CLI and the web app alike. Any plan may go back to the app's model; a model your plan does not include is refused, with the plans that include it (`rbai model list` shows them).

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | A model id from `rbai model list` |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_model_set` with `rbai mcp serve --tools model`.

```sh
rbai model set <id>
```

## rbai mcp

Use RBAi from MCP clients: serve, config snippets, tool list.

<a id="cmd-mcp-serve"></a>

### rbai mcp serve

Run the RBAi MCP server on stdio (started by an MCP client).

```text
rbai mcp serve [flags]
```

Uses the key of the current profile (or RBAI_API_KEY). Logs go to stderr; stdout is the protocol. By default it serves a small set of tools (`rbai mcp tools --tools default`) and rbai_agent_chat, the assistant itself. --tools adds whole command groups, or all of them; their destructive commands only with --allow-destructive. Signing in, API keys and local settings are never tools.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--tools <groups>` | string |  | Also serve these command groups, comma-separated (`rbai mcp tools` lists them), or all (default: the small default set) |
| `--allow-destructive` | boolean |  | Also serve the chosen groups' destructive commands (deletes); the client asks you before each call |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai mcp serve
rbai mcp serve --tools review,project,source   # Also every review, project and source command
rbai mcp serve --tools all --allow-destructive   # Everything that can be a tool, deletes included
rbai mcp serve --profile work
```

<a id="cmd-mcp-config"></a>

### rbai mcp config

Print the MCP config snippet for a client (never edits its files).

```text
rbai mcp config --client <value> [flags]
```

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--client <value>` | string: claude-desktop, claude-code, cursor, vscode, kiro, codex | required | The MCP client |
| `--transport <value>` | string: stdio, http | `stdio` | stdio: run `rbai mcp serve` locally; http: the hosted endpoint |
| `--use-path` | boolean |  | Use the bare `rbai` command (on PATH) instead of the absolute node + bundle path |
| `--tools <groups>` | string |  | Also serve these command groups, comma-separated (`rbai mcp tools` lists them), or all (default: the small default set) |
| `--allow-destructive` | boolean |  | Also serve the chosen groups' destructive commands (deletes); the client asks you before each call |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai mcp config --client claude-desktop
rbai mcp config --client claude-code
rbai mcp config --client cursor --tools review,galaxy,structure   # With more of the CLI as tools
rbai mcp config --client vscode --transport http
```

<a id="cmd-mcp-tools"></a>

### rbai mcp tools

The tool groups `rbai mcp serve --tools` can add, or (with --tools) the tools it serves.

```text
rbai mcp tools [flags]
```

Without --tools: the groups, with how many tools each adds and how many of them are destructive. With --tools default (or groups, or all): every tool that selection serves, with its input schema in -o json.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--tools <groups>` | string |  | Also serve these command groups, comma-separated (`rbai mcp tools` lists them), or all (default: the small default set) |
| `--allow-destructive` | boolean |  | Also serve the chosen groups' destructive commands (deletes); the client asks you before each call |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai mcp tools   # The groups
rbai mcp tools --tools default   # The tools served by default
rbai mcp tools --tools review,galaxy -o json
```

<a id="cmd-agent-skill"></a>

## rbai agent-skill

Teach the AI agent in your IDE to use rbai: skills, plugins and extensions (Claude Code, Kiro, Cursor, Codex, VS Code, Gemini).

```text
rbai agent-skill [flags]
```

Prints SKILL.md, generated from this version's commands and the agent guide. With --client and --write it creates the skill (SKILL.md and its references) where that client reads skills (your home folder; --project: this folder), or for Gemini CLI an extension, after asking (--yes without a terminal). --print shows those files first. --kit <dir> writes the whole agent kit: the skill, the Claude Code plugin and marketplace, the Kiro power, the Gemini CLI extension, AGENTS.md, Cursor and Copilot rules and the MCP Registry entry. It never replaces an existing file without --force and never edits any other file. For MCP tools as well, `rbai mcp config --client <name>` prints the snippet to paste.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--client <value>` | string: claude-code, kiro, cursor, codex, vscode, gemini |  | The client: claude-code, kiro, cursor, codex, vscode or gemini |
| `--write` | boolean |  | Create the files for --client (asks first) |
| `--print` | boolean |  | Print every file --write would create for --client, with its path (without --client: the whole kit) |
| `--project` | boolean |  | With --write or --print: this folder (the client's project location) instead of your home folder |
| `--kit <dir>` | string |  | Write the whole agent kit into this folder (asks first) |
| `--force` | boolean |  | With --write or --kit: replace files an earlier version wrote |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- `-o json`: without --write: {name, description, version, markdown} (with --print: {client, root, files: [{path, content}]}); with --write or --kit: {client, root, files, version, replaced}.
- MCP: not an MCP tool.

```sh
rbai agent-skill   # Print SKILL.md
rbai agent-skill --client claude-code --write   # ~/.claude/skills/rbai/ (SKILL.md and references/)
rbai agent-skill --client cursor --write --project   # .cursor/skills/rbai/ in this folder
rbai agent-skill --client gemini --print   # What the Gemini CLI extension holds, before writing it
rbai agent-skill --client kiro --write --force   # Replace it after an update
rbai agent-skill --kit ./rbai-agent-kit   # Every client's files, e.g. for Kiro's "Import power from a folder"
```

<a id="cmd-login"></a>

## rbai login

Sign in through the browser, or with an API key (= rbai auth login).

```text
rbai login [flags]
```

On a terminal this opens RBAi in the browser: approve the code shown here, and the server creates an API key named "RBAi CLI on <this computer>" for your account (listed in Settings → API keys, where you can revoke it). --no-browser prints the link instead (SSH, a machine without a browser). --paste takes a key you created in Settings → API keys; --with-token reads one from stdin. Every key is checked with the server before it is saved in the config directory (credentials.json, readable only by you). In CI, set RBAI_API_KEY instead of logging in.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--no-browser` | boolean |  | Print the sign-in link instead of opening a browser (SSH, headless) |
| `--paste` | boolean |  | Paste an API key from Settings → API keys instead of approving in the browser |
| `--with-token` | boolean |  | Read the key from stdin (e.g. `echo $KEY \| rbai auth login --with-token`) |
| `--web` | boolean |  | With --paste: open the API keys page in the browser without asking |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai auth login   # Approve this computer in the browser
rbai auth login --no-browser   # Over SSH: open the printed link on any device
rbai auth login --paste   # Paste a key created in Settings → API keys
rbai auth login --with-token < key.txt   # Read the key from a file (scripts, no terminal)
rbai auth login --profile staging --api-url https://staging.example.com/api   # A second account or server
```

<a id="cmd-logout"></a>

## rbai logout

Sign out of this computer (= rbai auth logout).

```text
rbai logout [flags]
```

A key from the browser sign-in (`rbai auth login`) belongs to this computer: logout revokes it on the server (DELETE /api-keys/<id>), so that sign-in ends everywhere, then removes it here. A key you pasted (--paste, --with-token) may be used elsewhere: logout only removes it from this computer, unless --revoke is given. If the server refuses the revoke, the key stays saved and the error says why. RBAI_API_KEY is never touched.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--revoke` | boolean |  | Also revoke a pasted key on the server (it stops working everywhere) |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai auth logout   # End the browser sign-in of this computer
rbai auth logout --revoke   # Also revoke a key you pasted
rbai auth logout --profile staging
```

<a id="cmd-whoami"></a>

## rbai whoami

Show the signed-in account (= rbai auth status).

```text
rbai whoami
```

Calls GET /auth/me with the current key. Exit code 3 when not signed in or the key is rejected.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai auth status
rbai auth status -o json   # For scripts
```

## rbai auth

Sign in and out, and see the current account.

<a id="cmd-auth-login"></a>

### rbai auth login

Sign in through the browser, or with an API key.

```text
rbai auth login [flags]
```

On a terminal this opens RBAi in the browser: approve the code shown here, and the server creates an API key named "RBAi CLI on <this computer>" for your account (listed in Settings → API keys, where you can revoke it). --no-browser prints the link instead (SSH, a machine without a browser). --paste takes a key you created in Settings → API keys; --with-token reads one from stdin. Every key is checked with the server before it is saved in the config directory (credentials.json, readable only by you). In CI, set RBAI_API_KEY instead of logging in.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--no-browser` | boolean |  | Print the sign-in link instead of opening a browser (SSH, headless) |
| `--paste` | boolean |  | Paste an API key from Settings → API keys instead of approving in the browser |
| `--with-token` | boolean |  | Read the key from stdin (e.g. `echo $KEY \| rbai auth login --with-token`) |
| `--web` | boolean |  | With --paste: open the API keys page in the browser without asking |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai auth login   # Approve this computer in the browser
rbai auth login --no-browser   # Over SSH: open the printed link on any device
rbai auth login --paste   # Paste a key created in Settings → API keys
rbai auth login --with-token < key.txt   # Read the key from a file (scripts, no terminal)
rbai auth login --profile staging --api-url https://staging.example.com/api   # A second account or server
```

<a id="cmd-auth-status"></a>

### rbai auth status

Show the signed-in account, plan, profile and key source.

```text
rbai auth status
```

Calls GET /auth/me with the current key. Exit code 3 when not signed in or the key is rejected.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_whoami`, served by `rbai mcp serve` by default.

```sh
rbai auth status
rbai auth status -o json   # For scripts
```

<a id="cmd-auth-logout"></a>

### rbai auth logout

Sign out: revoke the key the browser sign-in made, and remove it from this computer.

```text
rbai auth logout [flags]
```

A key from the browser sign-in (`rbai auth login`) belongs to this computer: logout revokes it on the server (DELETE /api-keys/<id>), so that sign-in ends everywhere, then removes it here. A key you pasted (--paste, --with-token) may be used elsewhere: logout only removes it from this computer, unless --revoke is given. If the server refuses the revoke, the key stays saved and the error says why. RBAI_API_KEY is never touched.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--revoke` | boolean |  | Also revoke a pasted key on the server (it stops working everywhere) |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai auth logout   # End the browser sign-in of this computer
rbai auth logout --revoke   # Also revoke a key you pasted
rbai auth logout --profile staging
```

<a id="cmd-auth-token"></a>

### rbai auth token

Print the API key of the current profile (for piping).

```text
rbai auth token
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
curl -H "Authorization: Bearer $(rbai auth token)" https://rbai.thedreamlabinnovations.com/api/usage/quota
```

## rbai profile

Your profile, thinking effort and public page.

<a id="cmd-profile-show"></a>

### rbai profile show

Your profile.

```text
rbai profile show
```

Aliases: `rbai profile get`, `rbai profile view`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_profile_show` with `rbai mcp serve --tools profile`.

```sh
rbai profile show
```

<a id="cmd-profile-update"></a>

### rbai profile update

Change profile fields ("" clears one).

```text
rbai profile update [flags]
```

Aliases: `rbai profile edit`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--name <text>` | string |  | New name |
| `--position <text>` | string |  | New position |
| `--institution <text>` | string |  | New institution |
| `--department <text>` | string |  | New department |
| `--orcid-id <text>` | string |  | New orcid id |
| `--research-interests <text>` | string |  | New research interests |
| `--bio <text>` | string |  | Bio (@file reads a file) |
| `--lab-website-url <text>` | string |  | New lab website url |
| `--google-scholar-url <text>` | string |  | New google scholar url |
| `--personal-website-url <text>` | string |  | New personal website url |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_profile_update` with `rbai mcp serve --tools profile`.

```sh
rbai profile update --institution "EMBL Heidelberg" --position "Postdoc"
rbai profile update --bio @bio.md
```

<a id="cmd-profile-effort"></a>

### rbai profile effort

Show or set your thinking effort (every model call made for you follows it).

```text
rbai profile effort [level]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[level]` | no | One of low, medium, high, max (omit to show it) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_profile_effort` with `rbai mcp serve --tools profile`.

```sh
rbai profile effort
rbai profile effort high
```

<a id="cmd-profile-page"></a>

### rbai profile page

Your public researcher page and its published items.

```text
rbai profile page
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_profile_page` with `rbai mcp serve --tools profile`.

```sh
rbai profile page -o json
```

## rbai usage

Credits, storage and Code sandbox time.

<a id="cmd-usage-show"></a>

### rbai usage show

Your plan, credits left, Code sandbox time and lab seat.

```text
rbai usage show
```

Aliases: `rbai usage quota`, `rbai usage credits`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_usage`, served by `rbai mcp serve` by default.

```sh
rbai usage show
rbai usage show -o json
```

<a id="cmd-usage-storage"></a>

### rbai usage storage

Storage used and the plan's quota.

```text
rbai usage storage
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_usage_storage` with `rbai mcp serve --tools usage`.

```sh
rbai usage storage
```

<a id="cmd-usage-compute-credits"></a>

### rbai usage compute-credits

Keep the code sandbox running on credits after the plan's Code sandbox time (on|off).

```text
rbai usage compute-credits <state>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<state>` | yes | on or off |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_usage_compute_credits` with `rbai mcp serve --tools usage`.

```sh
rbai usage compute-credits on
```

## rbai billing

Plans, your subscription and payments (checkout opens in the browser).

<a id="cmd-billing-plans"></a>

### rbai billing plans

Plans and top-up packs with their prices and limits.

```text
rbai billing plans
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai billing plans -o json
```

<a id="cmd-billing-subscription"></a>

### rbai billing subscription

Your subscription.

```text
rbai billing subscription
```

Aliases: `rbai billing status`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_billing_subscription` with `rbai mcp serve --tools billing`.

```sh
rbai billing subscription
```

<a id="cmd-billing-history"></a>

### rbai billing history

Your payments.

```text
rbai billing history
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_billing_history` with `rbai mcp serve --tools billing`.

```sh
rbai billing history -o json
```

<a id="cmd-billing-promo"></a>

### rbai billing promo

Check a promo code: the bonus credits it gives on a plan or a top-up.

```text
rbai billing promo <code> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<code>` | yes | The promo code |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--plan <tier>` | string |  | For a subscription to this plan (a paid tier from `rbai billing plans`) |
| `--topup <inr>` | number |  | For a top-up of this many rupees (or give neither flag for a top-up of any amount) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_billing_promo` with `rbai mcp serve --tools billing`.

```sh
rbai billing promo <code> --plan pro
rbai billing promo <code> --topup 500
```

<a id="cmd-billing-open"></a>

### rbai billing open

Open the pricing and checkout page: plans, the Labs plan, top-ups, promo codes (prints the URL without a terminal).

```text
rbai billing open
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai billing open
```

## rbai key

API keys for the CLI, scripts and MCP clients.

<a id="cmd-key-list"></a>

### rbai key list

Your API keys (never the keys themselves).

```text
rbai key list
```

Aliases: `rbai key ls`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai key list
```

<a id="cmd-key-create"></a>

### rbai key create

Create an API key; it is printed once (stdout) and never shown again.

```text
rbai key create <name> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | A name to recognise it by (at most 100 characters) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--expires-in-days <days>` | number |  | Expire after this many days (1-3650; default: never) |
| `--scope <scope>` | string |  | MCP scope: agent, core, extended, all, custom:<servers>, server:<server> (default: all) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai key create "CI pipeline" --expires-in-days 90 > ci-key.txt
```

<a id="cmd-key-delete"></a>

### rbai key delete

Revoke an API key.

```text
rbai key delete <id>
```

Aliases: `rbai key rm`, `rbai key revoke`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Key id (see `rbai key list`) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai key delete <id> --yes
```

<a id="cmd-key-servers"></a>

### rbai key servers

The MCP servers a key can be scoped to.

```text
rbai key servers
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai key servers
```

## rbai notification

Notifications.

<a id="cmd-notification-list"></a>

### rbai notification list

Your notifications.

```text
rbai notification list [flags]
```

Aliases: `rbai notification ls`.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--unread` | boolean |  | Only unread ones |
| `-L, --limit <n>` | number | `50` | At most this many |
| `--offset <n>` | number | `0` | Skip this many |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_notifications`, served by `rbai mcp serve` by default.

```sh
rbai notification list --unread
```

<a id="cmd-notification-count"></a>

### rbai notification count

How many notifications are unread.

```text
rbai notification count
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_notification_count` with `rbai mcp serve --tools notification`.

```sh
rbai notification count
```

<a id="cmd-notification-read"></a>

### rbai notification read

Mark a notification read (or all with --all).

```text
rbai notification read [id] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[id]` | no | Notification id |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--all` | boolean |  | Mark every notification read |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_notification_read` with `rbai mcp serve --tools notification`.

```sh
rbai notification read <id>
rbai notification read --all
```

<a id="cmd-notification-delete"></a>

### rbai notification delete

Delete a notification.

```text
rbai notification delete <id>
```

Aliases: `rbai notification rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Notification id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_notification_delete` with `rbai mcp serve --tools notification` `--allow-destructive`.

```sh
rbai notification delete <id> --yes
```

## rbai memory

What RBAi remembers: your memory folder, your memories and a project's memory.

<a id="cmd-memory-files"></a>

### rbai memory files

Your memory folder's files (/memories), or a project's (/project): what every new chat reads.

```text
rbai memory files [flags]
```

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--project <id>` | string |  | A project's folder (/project) instead of yours (/memories) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: {enabled, root, limits, files: [{path, size, updatedAt}]}.
- MCP: `rbai_memory_files`, served by `rbai mcp serve` by default.

```sh
rbai memory files
rbai memory files --project <id>
```

<a id="cmd-memory-read"></a>

### rbai memory read

Print one memory file (Markdown).

```text
rbai memory read <path> [flags]
```

Aliases: `rbai memory cat`.

| Argument | Required | Description |
| --- | --- | --- |
| `<path>` | yes | Its path, as `rbai memory files` lists it (/memories/profile.md) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--project <id>` | string |  | A project's folder (/project) instead of yours (/memories) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- `-o json`: {path, text, etag, size}.
- MCP: `rbai_memory_read` with `rbai mcp serve --tools memory`.

```sh
rbai memory read /memories/profile.md
rbai memory read /project/facts.md --project <id>
```

<a id="cmd-memory-delete-file"></a>

### rbai memory delete-file

Delete one memory file or folder.

```text
rbai memory delete-file <path> [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `<path>` | yes | Its path (/memories/notes.md) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--project <id>` | string |  | A project's folder (/project) instead of yours (/memories) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_memory_delete_file` with `rbai mcp serve --tools memory` `--allow-destructive`.

```sh
rbai memory delete-file /memories/notes.md --yes
```

<a id="cmd-memory-list"></a>

### rbai memory list

What RBAi remembers about you, and whether memory is on.

```text
rbai memory list
```

Aliases: `rbai memory ls`, `rbai memory show`.

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_memory_list` with `rbai mcp serve --tools memory`.

```sh
rbai memory list
rbai memory list -o json
```

<a id="cmd-memory-enable"></a>

### rbai memory enable

Turn memory on.

```text
rbai memory enable
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_memory_enable` with `rbai mcp serve --tools memory`.

```sh
rbai memory enable
```

<a id="cmd-memory-disable"></a>

### rbai memory disable

Turn memory off (nothing new is remembered).

```text
rbai memory disable
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: `rbai_memory_disable` with `rbai mcp serve --tools memory`.

```sh
rbai memory disable
```

<a id="cmd-memory-delete"></a>

### rbai memory delete

Forget one memory.

```text
rbai memory delete <id>
```

Aliases: `rbai memory rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<id>` | yes | Memory id |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_memory_delete` with `rbai mcp serve --tools memory` `--allow-destructive`.

```sh
rbai memory delete <id> --yes
```

<a id="cmd-memory-clear"></a>

### rbai memory clear

Forget everything RBAi remembers about you.

```text
rbai memory clear
```

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_memory_clear` with `rbai mcp serve --tools memory` `--allow-destructive`.

```sh
rbai memory clear --yes
```

<a id="cmd-memory-project-show"></a>

### rbai memory project show

What a project remembers (summary, entities, facts, notes).

```text
rbai memory project show [project]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: read-only.
- Credits: none.
- MCP: `rbai_memory_project_show` with `rbai mcp serve --tools memory`.

```sh
rbai memory project show <project id> -o json
```

<a id="cmd-memory-project-clear"></a>

### rbai memory project clear

Clear part or all of a project's memory.

```text
rbai memory project clear [project] [flags]
```

| Argument | Required | Description |
| --- | --- | --- |
| `[project]` | no | Project id (default: the profile's project) |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--part <value>` | string: all, summary, entities, facts | `all` | Which part |
| `--note <id>` | string |  | Delete one note instead |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: `rbai_memory_project_clear` with `rbai mcp serve --tools memory` `--allow-destructive`.

```sh
rbai memory project clear <project id> --part facts --yes
```

## rbai config

Settings and profiles.

<a id="cmd-config-get"></a>

### rbai config get

Print one setting.

```text
rbai config get <key>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<key>` | yes | One of: apiUrl, webUrl, output, project, theme, notify |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config get apiUrl
```

<a id="cmd-config-set"></a>

### rbai config set

Change a setting of the current profile (theme and notify: of every profile).

```text
rbai config set <key> <value>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<key>` | yes | One of: apiUrl, webUrl, output, project, theme, notify |
| `<value>` | yes | The new value |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config set output json   # JSON by default
rbai config set theme light   # Colours for a light terminal (dark, light, auto or mono)
rbai config set notify bell   # Ring the bell when a long answer finishes
rbai config set project 3f2c9e7a-…   # Default project for --project
```

<a id="cmd-config-unset"></a>

### rbai config unset

Remove a setting from the current profile.

```text
rbai config unset <key>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<key>` | yes | One of: apiUrl, webUrl, output, project, theme, notify |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config unset project
```

<a id="cmd-config-list"></a>

### rbai config list

Show every setting with its value and source.

```text
rbai config list
```

Aliases: `rbai config ls`.

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config list
rbai config list --profile local
```

<a id="cmd-config-profile-list"></a>

### rbai config profile list

List profiles.

```text
rbai config profile list
```

Aliases: `rbai config profile ls`.

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config profile list
```

<a id="cmd-config-profile-show"></a>

### rbai config profile show

Show the current profile.

```text
rbai config profile show
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config profile show
```

<a id="cmd-config-profile-use"></a>

### rbai config profile use

Make a profile the default.

```text
rbai config profile use <name>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Profile name (created when new) |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config profile use local
```

<a id="cmd-config-profile-delete"></a>

### rbai config profile delete

Delete a profile and its saved key.

```text
rbai config profile delete <name>
```

Aliases: `rbai config profile rm`.

| Argument | Required | Description |
| --- | --- | --- |
| `<name>` | yes | Profile name |

- Sign-in: not needed.
- Changes: **destructive**: deletes or irreversibly changes data; asks first, and needs `--yes` with `--no-input` or without a terminal.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai config profile delete staging --yes
```

<a id="cmd-api"></a>

## rbai api

Make an authenticated request to any RBAi API route.

```text
rbai api <path> [flags]
```

The path is relative to the API base (`rbai api /projects` calls <apiUrl>/projects). Fields become the query string for GET and a JSON body otherwise; the method defaults to GET, or POST when fields or --input are given. The response body goes to stdout (JSON pretty-printed); a non-2xx response exits with the mapped exit code (`rbai help exit-codes`). An event stream (text/event-stream) is printed as it arrives, with no total time limit, until it ends or sends nothing for 60 s. Ctrl-C only stops reading it: to stop a plot edit's model call too, use `rbai plot edit`.

| Argument | Required | Description |
| --- | --- | --- |
| `<path>` | yes | API path, e.g. /projects or /usage/quota |

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `-X, --method <method>` | string: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS |  | HTTP method |
| `-f, --field <key=value>` | list (repeatable, or comma-separated) |  | String field |
| `-F, --raw-field <key=value>` | list (repeatable, or comma-separated) |  | Typed field: numbers, true, false, null, @file |
| `--input <file>` | string |  | Raw JSON body from a file, or - for stdin |
| `-H, --header <Name: value>` | list (repeatable, or comma-separated) |  | Extra request header |
| `-i, --include` | boolean |  | Print the status line and response headers before the body |

- Sign-in: needs a key (`rbai auth login` or RBAI_API_KEY).
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai api /auth/me   # Who am I
rbai api /projects -f search=crispr -f limit=5   # Query string for GET
rbai api -X POST /projects -f title="Spike protein" -f description="Variants of concern"   # JSON body
rbai api /notifications --query "notifications[?!read].title"   # Filter with JMESPath
```

<a id="cmd-commands"></a>

## rbai commands

List every command (use --json for the full machine-readable tree).

```text
rbai commands
```

With -o json: the whole tree with args, typed flags, defaults, examples, destructive/readOnly, credits, --wait, -o json shapes and MCP tool names, plus the global flags, environment variables and exit codes.

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- `-o json`: {name, version, globalFlags, exitCodes, environment, commands}: each command {path, summary, args, flags, examples, destructive, readOnly, auth, credits, wait, returns, mcpTool}.
- MCP: not an MCP tool.

```sh
rbai commands
rbai commands --json   # For agents
```

<a id="cmd-help"></a>

## rbai help

Help for a command or a topic: environment, exit-codes, output, agents, reference.

```text
rbai help [topic...]
```

Topics print offline. `rbai help agents` is the guide for AI agents and scripts; `rbai help reference` is every command as Markdown (the same as REFERENCE.md in the package; with -o json it points to `rbai commands --json`, the same data as JSON).

| Argument | Required | Description |
| --- | --- | --- |
| `[topic...]` | no | A topic, or a command path such as "project list" |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai help agents
rbai help reference > REFERENCE.md   # Every command, offline
rbai help exit-codes
rbai help project create
```

<a id="cmd-completion"></a>

## rbai completion

Print a shell completion script (bash, zsh, fish, powershell).

```text
rbai completion <shell>
```

| Argument | Required | Description |
| --- | --- | --- |
| `<shell>` | yes | One of: bash, zsh, fish, powershell |

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
eval "$(rbai completion bash)"   # bash, in ~/.bashrc
rbai completion fish > ~/.config/fish/completions/rbai.fish   # fish
rbai completion powershell | Out-String | Invoke-Expression   # PowerShell, in $PROFILE
```

<a id="cmd-doctor"></a>

## rbai doctor

Check Node, the config directory, the API and the key.

```text
rbai doctor
```

Runs: Node version, config directory permissions, GET /health (no key), GET /auth/me (with the key); shows the proxy requests use and how the terminal is drawn.

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai doctor
rbai doctor -o json   # For scripts
```

<a id="cmd-update"></a>

## rbai update

Update rbai to the newest version (shows the command, runs it when you say yes).

```text
rbai update [flags]
```

Aliases: `rbai upgrade`.

Reads the newest version and prints the command that updates this copy: npm install -g rbai-cli@latest (or pnpm, yarn, bun or volta when it was installed with one of those), or, for the standalone binary that install.sh or install.ps1 installed, that installer again for the same folder, with the newest version read from https://cli.thedreamlabinnovations.com/latest.json. On a terminal it asks before running it; --yes runs it without asking; --check only reports. A binary that came some other way, or a copy built from source, gets the steps instead of a command.

| Flag | Type | Default | Description |
| --- | --- | --- | --- |
| `--check` | boolean |  | Only report whether a newer version exists (exit 0 either way) |

- Sign-in: not needed.
- Changes: creates or changes data.
- Credits: none.
- MCP: not an MCP tool.

```sh
rbai update
rbai update --check -o json
rbai update --yes   # Update without asking
```

<a id="cmd-version"></a>

## rbai version

Print the CLI version and runtime.

```text
rbai version
```

- Sign-in: not needed.
- Changes: read-only.
- Credits: none.
- `-o json`: {version, node, platform, arch, apiUrl, profile}.
- MCP: not an MCP tool.

```sh
rbai version
rbai version -o json
```
