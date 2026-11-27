# Changelog

All notable changes to the RBAi CLI (`rbai`, npm package `rbai-cli`).

## 1.6.9 (27 Nov 2026)
Fixed:
- When a long answer that went on in the background failed on the server, `rbai ask`, `rbai chat` and
  `rbai connect chat` could print the server's first status line, "Agent response continuing", as the error.
  That happened when the server had already stored the answer as failed before the CLI read it. They now print
  the reason the server stored, such as "This answer stopped: the process running it ended. The work above is
  kept."

## 1.6.8 (26 Nov 2026)
Fixed:
- A long answer that the server finished in the background is no longer lost when a background agent's reply
  starts in the same chat right after it. 1.5.0 to 1.6.7 followed the chat's latest background turn, so they read
  the reply's id, and 30 s into following gave up with exit 7 ("no continued run of it was found") although the
  answer was stored. `rbai ask`, `rbai chat` and `rbai connect chat` now follow the answer's own record, and once
  they have seen it they never time out for "no run found".
Changed:
- `rbai model list` shows which plans include each model and whether yours does (Plans, On your plan). With
  `-o json`, `available` gives the models your plan may choose and `plans` the plans that include each other model.
- `rbai model set <id>` refuses a model your plan does not include with one sentence naming the plans that do
  (exit 5, code plan_required), before anything is saved. The help no longer names a plan.
## 1.6.7 (22 Nov 2026)
Added:
- `rbai review figures [on|off]` shows or sets Settings > Model & approvals > Read figures in literature reviews:
  whether your reviews read the papers' figure images. Pro and lab seats can turn it on (on by default);
  on another plan `on` is refused with one sentence, and reviews skip the figure stage. A review decides once, when
  it starts, and its Methods say whether figures were read and why.
- `rbai review conversation <id>` prints the questions asked about a review, here or in the web app's Ask the
  papers, with their answers, oldest first. `--clear` deletes them, so the next question starts a new conversation.
Changed:
- `rbai review watch` and `rbai review create --wait` give the review's credits so far on each progress line.
- `rbai review show` (and the summary of `--wait`) gives what the review was charged once it is settled, or that it
  was not charged.

Server changes, 22 Nov 2026 (1.6.6 gets them too):
- `rbai review ask` keeps a conversation: the server stores each question with its answer and gives the model the
  last finished ones, so a follow-up question needs no context of its own. A question no longer stops at 120 s; it
  has the request's own time.
- A stopped answer (Ctrl-C, or Stop in the web app) is charged by one rule everywhere: the model calls that
  finished, and the call the Stop cut at its input as sent, with the cache share of the answer's earlier calls, plus
  the text it streamed. Before, `rbai ask` and `rbai galaxy ask` charged nothing for the cut call, and
  `rbai review ask` charged its whole prompt at the uncached price.
- In stream-json, a `tool-result` event's output text gives each figure stored with the chat as `url`, a signed link
  that works for an hour or more, instead of its base64, which was cut at 4,096 characters. Its `file` events are
  unchanged, and `rbai session file <session> <name>` still downloads any file.

## Server change, 21 Nov 2026 (no new CLI version)
Changed:
- In stream-json, a `tool-result` event's `output` names each figure and saved file without its bytes. Their base64
  was cut at 4,096 characters there, so no reader could use it. Each figure still comes whole in its `file` event, and
  `rbai session file <session> <name>` downloads any file.

## 1.6.6 (16 Nov 2026)
Fixed:
- `rbai ask` (and `rbai connect ask`, `rbai galaxy ask`) says a long turn is still working. Every 30 s while the turn
  runs, one line on stderr (stream-json: a `progress` event) gives its phase (answering; answering on the server,
  where a long answer goes on after its first run; waiting for the answer already running in the chat), its steps and
  tool calls, and, with stream-json, its credits so far, all as the server last sent them. Before, a turn that went
  on on the server, or waited for the chat's running answer, printed nothing for half an hour.
- `rbai ask` returns when the server's turn ends, whatever happens to its connection. When a stream brings only the
  server's heartbeat for a minute, the CLI asks the server for its own record of the answer; when the answer is
  stored, or goes on in the server's background runner, the CLI follows that record to the end instead of the quiet
  stream. Before, a turn whose stream went quiet could finish on the server while `rbai ask` kept waiting for hours.
- When an answer starts a background job, `rbai ask` prints the job's name and id with `rbai job watch <id>`
  (json and stream-json: `background.jobIds` and `background.watch`), beside the existing `rbai session wait` line
  for RBAi's reply when the job ends.

## 1.6.5 (13 Nov 2026)
Changed:
- `rbai researcher labs` is RBAi's one lab search, in Connect: it sends one message to RBAi in Connect, as
  `rbai connect ask` does, so the web's Connect and the terminal give the same answer to the same request. It shows
  how many papers and labs match and what reading every lab would cost before any paper is read, each lab as its
  paper is read, then every lab found in rank order. At its budget (40 credits, or `--budget <credits>`) it asks
  "Read about N more papers for about X credits?" (y/N); y goes on in the same conversation, and a lab already read
  costs nothing again. Ctrl-C is Connect's Stop. `--resume` (now a switch, with the same item and country) goes on
  where a search stopped, also days later: the search is kept with your Connect conversation. `--papers` lists one
  row a paper. The search keeps running on the server if the terminal closes; `rbai connect show` prints its answer.
- The old server search it called (`GET /researchers/labs`) is gone: 1.6.4 and earlier get one sentence that says to
  run `rbai update`, or to ask with `rbai connect ask`.
- `rbai ask --output-format stream-json` (and `rbai connect ask`) has a `tool-progress` event: a running tool's
  progress line, and the lab search's first line and each lab as it is read.

## 1.6.4 (13 Nov 2026)
Fixed:
- Ctrl-C on `rbai review ask` now reaches the server. In 1.6.3 the same Ctrl-C also cancelled the stop request, so
  the CLI said "The stop did not reach the server" and the answer ran to its end. Now the first Ctrl-C ends the
  answer and sends the stop; the CLI says "Stopped the answer" once the server has it, and only what ran is charged.
  A second Ctrl-C while the stop is on its way says so; a third leaves at once.

## 1.6.3 (13 Nov 2026)
New:
- `rbai plot edit` uses the checked edit: RBAi runs the new code, looks at the finished figure, fixes what it sees
  wrong (at most twice) and then saves it, with a line saying whether the figure was checked. A figure drawn by an
  R script or a script file is edited as that script, in its own language, and run the same way; its edit is saved
  as the script plus `<name>.figure.json`, which `--code` reads for the next edit.
- `rbai researcher labs` streams: first how many papers match and what reading every lab would cost, then each lab
  as its paper is read, with its sentence and the running cost. `--budget <credits>` sets how much one search may
  spend; at the budget it asks "Read more?" on a terminal (y/N). `--resume <search id>` reads on from where a search
  stopped; papers already read cost nothing again. `--effort` sets the thinking level. Ctrl-C stops the search on
  the server.
- `rbai review ask` sends a stop to the server when it gives up on an answer (Ctrl-C, 120 s with nothing
  received, a broken connection), and says if the stop did not arrive. Its Ctrl-C case did not work until 1.6.4.

## 1.6.2 (12 Nov 2026)

New:
- `rbai plot edit` is Edit with AI for a chat's figure, in the terminal, as on the website. Name the chat with
  `--session <id>`: it edits the newest figure an answer drew in Python, the one `--figure <file name>` names, or a
  program you give with `--code <file.py>`. While the model works you see the time, its latest line of thinking and
  what it is doing ("Writing the code", "Running it in the sandbox"). The new code runs in the chat's code sandbox,
  next to the chat's files. When it fails there, the error goes back to the model, which corrects it, until the
  figure is drawn. The figure is saved here under its "-edit" name, with its program beside it (.py), so the next
  edit can start from it with `--code`. At the end you get the model's line about what changed, and the credits.
  When no change to the code can do what you asked, it says why and exits 0. `--effort` sets the thinking effort of
  the edit; `-o json` prints `{code, reply, cannot, image, usage, …}`.
- An edit has no time limit. A request with many changes at max effort can take about 4 minutes (an 8-change
  request took 242 seconds on 12 Nov). It stops only when nothing at all, not even the server's heartbeat every
  15 seconds, arrives for 60 seconds.
- Ctrl-C stops the edit on the server too, as closing the editor does on the website, so its model call doesn't
  run on; what it ran is charged, as for a chat's Stop. The stop is also sent when the 60-second guard ends an
  edit, when the connection breaks, and when you close the terminal. The CLI says when a stop did not reach the
  server.

Fixes:
- `rbai api` prints an event stream (text/event-stream) as it arrives, with no total time limit, until it ends or
  sends nothing for 60 seconds. 1.6.1 waited for the whole response under the 30-second request timeout: on 12 Nov,
  `rbai api /agent/plot-edit` gave up on an edit after 30 seconds while the server's model call ran 4 more minutes
  and was still charged. In `rbai api`, Ctrl-C only stops reading; `rbai plot edit` also stops the model call.

## 1.6.1 (11 Nov 2026)

Fixes:
- `rbai researcher labs` waits up to 80 seconds for its answer. Europe PMC took 15 to 20 seconds to answer a Methods
  search of a term it had not been asked about recently (measured on 11 Nov), so the server now gives that search
  40 seconds instead of 10, and one search for labs can take about a minute. 1.6.0 stopped waiting after 30 seconds
  and reported a timeout while the server was still searching. With 1.6.0, `--timeout 80` waits as long.
- Galaxy jobs that RBAi cannot read on their Galaxy server (for example, when no key for that server is saved) now
  say so: the server marks them `unchecked`, with the reason, instead of leaving them "running". `rbai job list`,
  `rbai job show` and `rbai job watch` show "not checked"; `rbai galaxy jobs` shows the state in words and a new Note
  column with the reason and what to do, such as `rbai galaxy key set --server <url>`. `rbai job watch` keeps
  waiting while a job is not checked and shows the reason; 1.6.0 would have called it failed. JSON output keeps the
  server's value, `unchecked`.

## 1.6.0 (11 Nov 2026)

**Everything the website gained since 1.5, in the terminal.** The server's part was already shared; these are the
CLI's own parts.

- **Background agents.** When RBAi starts an agent that works in the background (its own budget and deadline), the
  chat shows its end, its question or its request for more credits or time, and then RBAi's reply to it, as they
  come. `/specialists` lists the chat's agents with their state and credits, shows one's task and
  report, answers what it asks, sends it a message and stops it. A request for more is answered as data: the option
  you pick (Allow, Write the report now, Stop) or `--choice allow|report|stop` with `--credits`/`--minutes`; your own
  words go to the server as you typed them, and the server's model reads them. `rbai specialist list|show|answer|message|stop`
  does the same from a script.
- **Replies to background work.** A background agent's end and a background job's end wake RBAi in the chat; the
  chat (full-screen and `--plain`) shows the event's line and follows RBAi's reply while you wait. After `rbai ask`,
  `rbai session wait <id>` waits for that reply and prints it (text or JSON), and `rbai ask` says on stderr (and in
  the JSON's `background`) when its answer left work running.
- **Type while RBAi answers.** Enter sends your message to the running answer, which reads it at its next step; the
  chat says when it was read, or that the next turn reads it. Until 1.6 the chat refused it.
- **One answer at a time.** A message sent while another answer of the chat runs (another window, or RBAi's reply to
  background work) goes to that answer, which is followed here; when no run can take it, it waits for that answer's
  end and is sent then. "Still answering" and "already answered" refusals say where the answer is.
- **Files.** Word and Excel files RBAi builds on the server, files of the code sandbox and files and folders on a
  project's computer are full links in the chat, and `/download <n>` or `rbai session save <link>` saves them: large
  computer files through the server's copy, with its progress; a folder lists its files. Images an answer places
  show their caption, credit and licence and are in `/files`. `rbai ask` lists them on stderr with the command that
  saves each.
- **Answer lines.** A failed answer shows the server's own notice once ("Failed. … It was not charged.") and its line
  says "not charged"; the "Summarizing the earlier part of this long conversation" status shows before such an
  answer; `rbai ask` prints the answer's credits on stderr, as the web shows them.
- **Memory folder and projects.** `rbai memory files` and `rbai memory read <path>` (also `--project <id>`) show the
  memory files every new chat reads; `/memory` lists them. `rbai project computer <id>` shows a project's cloud
  computer and pauses or restarts it.
- **Fixed:** `rbai session show` printed answers as their stored JSON; it prints their text, and background events as
  their lines.

## 1.5.0 (7 Nov 2026)

**Your own tools.** List MCP tool servers in a folder's `.mcp.json` (the format Claude Code uses, so a lab can share
one file) or in your own `mcp.json` in the CLI's config folder. In a chat in that folder, rbai starts them on this
computer, and RBAi loads their tools when a task needs them, as it loads its own databases.

- **Trust first:** a folder's servers start only after you trust its `.mcp.json` once: the chat asks before your
  first message, `rbai bridge` asks in its window, or run `rbai tools trust`. A changed `.mcp.json` asks again. Your
  own `mcp.json` needs no trust. `rbai ask --local` starts them only with `--allow tools`.
- **Asking first:** in ask and edit mode RBAi asks before each call; the box names the server, the tool and its
  arguments. "Yes, and don't ask again" keeps that tool for the folder; `/tools allow <server>[/<tool>]` allows one
  for this session (`--folder`: for the folder). Plan and read-only modes use only the tools their server marks
  read-only, and refuse the rest.
- **What stays on this computer:** a server's command, URL, headers and environment variables (`${VAR}` and
  `${VAR:-default}` are read from your environment). Only the tools' names, descriptions and input schemas go to
  RBAi, and what a tool returns when RBAi calls it.
- **Big results** (over 25,000 characters) are saved whole in the CLI's state folder (`tool-results`, kept 7 days),
  and RBAi reads them in parts. Images a tool returns are saved there too, and RBAi can look at them.
- **`rbai tools`** lists the servers, where each is listed, its state and its tools; `rbai tools trust` and
  `rbai tools forget` set and clear the folder's trust (and its allowed tools). In a chat, `/tools` shows the same.
- **Programs already on this computer:** RBAi now checks that a program is installed (its version command) before it
  relies on it.
- **rbai bridge:** website chats in the folder get the same tools, and the browser's Work log and approval name the
  tool server.
- **Changed:** `rbai tools` was another name for `rbai tool` (RBAi's own tool catalogue) until 1.4; that command is
  `rbai tool`. The server offers tool servers' tools only to rbai 1.5.0 or later; older versions keep their tools.

## 1.4.0 (7 Nov 2026)

**Background jobs.** In a chat in a folder, RBAi can start a long command (an alignment, a Nextflow pipeline, a large
download) as a background job that keeps running after the chat, after rbai closes and after its terminal window
closes. Its output goes to a log file. RBAi says the job's id and finishes its answer instead of waiting.

- **Asking first:** starting a job asks as any command does, and the box says that the command keeps running in the
  background after this chat; edit mode and saved command rules work as for commands; plan and read-only modes start
  none. Stopping a job asks in ask mode. `rbai ask --local` starts or stops one only with `--allow run` (or a matching
  `--allow "run:..."`).
- **Later, in any folder:** ask RBAi whether a job is still running or how it ended (with its exit code), to show the
  end of its log, or to stop it. In plan and read-only modes RBAi can still check a job and read its log.
- **`rbai jobs`** lists the current folder's jobs (`--all`: every folder's); `rbai jobs log <id>` prints the end of a
  log (`--lines`, `--offset`); `rbai jobs stop <id>` stops a job and every program it started; `rbai jobs clean`
  removes the jobs that ended more than 7 days ago, and their logs, after asking. Nothing is deleted on its own. They
  need no sign-in.
- **What can end a job:** a computer that sleeps pauses it; a restart ends it (Windows updates can restart the
  computer on their own). A job that ended so, without an exit code, shows as "ended, exit code unknown", never as
  running, also when another program got its process id.
- **rbai bridge:** website chats in the folder get background jobs too, and the browser's approval says that the
  command keeps running after the chat.
- **Changed:** `rbai jobs` was another name for `rbai job` (the server's jobs) until 1.3; that command is `rbai job`.
  Until 1.3 a background command stopped when you left rbai, which asked first; now it keeps running, so leaving asks
  nothing. The server offers background jobs only to rbai 1.4.0 or later; older versions keep their tools.
- **How this release was tested:** every binary was built from the one bundle (Bun 1.4.3). The Linux x64 builds
  ran, with a background job that outlived the CLI and its terminal session; the Windows x64 build ran on a Windows
  computer; the macOS builds are signed (ad hoc) but were not run on a Mac; the Arm and musl builds had their format
  checked and were not run. The npm package is the same bundle.

## 1.3.0 (6 Nov 2026)

**Your folder from the website** (`rbai bridge`). Run `rbai bridge` in a folder and leave it running: a chat on the
website can then work in that folder, live, the way `rbai` does in a terminal. The same works on a lab's Linux server:
run it there, and the website uses that server's folder and processors.

- **Link your browser once:** in the website, Settings, Your computers, Link this browser. `rbai bridge` shows the
  request with the browser's key in four groups and asks `Allow? [y/N]`; the website shows the same key.
- **Approvals in the browser, checked here:** reads and searches inside the folder run without asking, as in local
  mode; every change, command and upload waits for your answer in the browser. The answer runs only if it is signed
  by a browser linked here, over this computer's own card; anything else is a No, told to RBAi as "The approval could
  not be checked on this computer." and written in the action log as unverified.
- **`--mode ask|edit|read`** sets the most RBAi may do in the folder; the website can ask for less, never more.
  `/mode`, `/undo`, `/rewind`, `/local log`, `/local rules` and `/exit` work in its window; Ctrl-C asks first while
  a command runs.
- **`rbai bridge --forget-browsers`** unlinks every browser linked with this computer for your account, and stops.
- **Offline and back:** it polls the server (every 0.7 s while a chat uses the folder, 10 s otherwise), says when the
  server cannot be reached, and tries again after 1, 2, 5, then every 10 seconds. A call whose computer has not
  polled for a minute ends, and RBAi is told the computer went offline.
- `rbai`, `rbai chat` and `rbai ask --local` are unchanged.
- **How this release was tested:** every binary was compiled from the one bundle on Linux (Bun 1.4.3). The Linux x64
  builds ran there and the Windows x64 build ran on a Windows computer; the macOS builds are signed (ad hoc) but were
  not run on a Mac; the Arm and musl builds had their format checked and were not run. The npm package is the same bundle.

## 1.2.0 (6 Nov 2026)

**RBAi works in your folder** (local mode), for everyone: the betas 1.2.0-beta.1 to beta.5 in one release. Started in a
folder, `rbai` reads, searches and edits the files there and runs your programs on your computer, asking first, next
to every RBAi cloud tool. The user guide: https://rbai.thedreamlabinnovations.com/docs/cli-access#local.

- **The local tools:** read a file (2,000 lines at a time from any line, any size; gzip text such as FASTQ.gz and
  VCF.gz unpacked as it is read), list the folder, find files, search their text, edit and write files (their line
  endings and encoding kept), run commands and background jobs, send a file to the chat's cloud sandbox (up to 25 MB)
  and save a sandbox file into the folder.
- **PDFs and pictures** in the folder are read: RBAi sends them with your message, as `@` does (PNG, JPEG, WebP and
  GIF are read; TIFF and BMP are sent, and RBAi asks to convert them).
- **The folder question** the first time in a folder: Yes, Read only or No, remembered for the folder; in your home
  folder or a drive's root, Enter means No. `/local on`, `/local read` and `/local off` change it.
- **An approval box** before every change, every command and every upload, showing exactly what will happen: the
  command and the folder it runs in, the file and a coloured diff, or the file for the cloud sandbox and its size.
  1 Yes, 2 Yes and don't ask again, 3 No and tell RBAi what to do instead; Esc means No. A command with shell
  operators (`;` `&` `|` `<` `>`, a backtick, `$(`) never gets "don't ask again". Uploads ask wherever the file is,
  in every mode: "It will be stored in this chat's cloud sandbox."; 2 says yes to this folder's uploads until rbai
  ends.
- **Four modes** on Shift+Tab, `/mode` or `rbai chat --mode`: asks before changes (the default), edits without asking
  (commands and uploads still ask), plan first (a numbered plan, then **Go ahead with this plan?**), read only.
- **`/undo` and `/rewind`** put files back; **`/local log`** shows what RBAi did; **`/local rules`** lists the commands
  allowed with "don't ask again", and `/local rules remove <n>` takes one back. All of it is kept in rbai's own
  folders, never in yours.
- **RBAI.md** (else AGENTS.md) is read with every message as the folder's notes, and `/init` has RBAi write one.
- **One shell for the whole chat:** a `cd` or a variable carries over to the next command; after the first, commands
  start at once (on Windows PowerShell 5.1, about 10 ms instead of 3.6–5.4 s). `/jobs` lists the commands running on
  this computer; they stop when you leave rbai, which asks first.
- **`rbai ask --local [folder]`** for scripts and agents: never a prompt. `--allow edit`, `--allow upload`,
  `--allow run` and `--allow "run:<program> <first argument>"` say what may change, be uploaded or run; anything else
  goes back to RBAi as not allowed, naming the flag. stream-json gains `local-call` and `local-result` events.
- **`rbai --no-local`** or `rbai chat --no-local` starts without the folder; `rbai --dir <folder>` works in another
  one, and `rbai --mode <mode>` starts in a mode (`rbai chat` takes both too).
- In Windows' classic console, the welcome says: "For colours and the RBAi logo, open this in Terminal."
- Fixed during the betas: commands in a folder whose path has `[` or `]` ran in another folder (Windows); PowerShell
  errors reached RBAi as XML; reading the end of a large file was slow (a 383 MB FASTQ: 33 s, now 8 s); a long line, or
  the thinking above a new box, left copies of itself on the screen; on a busy computer, a message whose last letters
  and Enter arrived together got a new line instead of being sent. Plan mode now tells RBAi the folder is read-only
  only until you approve the plan.

## 1.2.0-beta.5 (6 Nov 2026)

The fifth beta of local mode (install it with `RBAI_VERSION=1.2.0-beta.5`; 1.1.2 stays what new installs and
`rbai update` get):

- **Uploads ask first.** Before RBAi copies a file to the chat's cloud computer, a box shows the file and its size
  and says "It will be stored in this chat's cloud computer." This now happens for files inside the folder too, in
  every mode (until beta.4 they went without asking). 2 says yes to this folder's uploads until rbai ends; 3 or Esc
  says no. `rbai ask --local` uploads only with `--allow upload`. Reading a PDF or a picture in the folder is still a
  read and does not ask.
- **Enter sends on a busy computer.** When a message's last letters and Enter reached rbai together (Windows Terminal
  on a busy computer), the box got a new line instead of sending the message. Now the message is sent.
- **Plan mode** asks for a plan whose changes are made once you approve it: beta.4's plans could end "I can't edit
  … even after approval".
- **`rbai --no-local`**, `rbai --dir <folder>` and `rbai --mode <mode>` work on `rbai` alone, as on `rbai chat`.

## 1.2.0-beta.4 (6 Nov 2026)

The fourth beta of local mode (install it with `RBAI_VERSION=1.2.0-beta.4`; 1.1.2 stays what new installs and
`rbai update` get). From testing beta.3 in Windows Terminal:

- **Commands run in a shell that stays open**, one per chat: a `cd` or a variable set by one command is there for
  the next, inside the folder (a command that ends outside it sends the next one back, and RBAi is told). After the
  first, a command starts at once: on Windows PowerShell 5.1, 10 ms instead of 3.6–5.4 s. The first starts while its
  card waits for you. A timeout or Esc stops the command and its shell; the next one starts in a new shell, and RBAi is
  told the folder and variables were reset. The card shows the folder the command will run in.
- **No more copies of the thinking and the card on the screen** when a card opened below a long answer (the screen
  was taller than the window): the live part of the screen now always fits in the window.
- **Plan mode**, a fourth mode on Shift+Tab (ask, edit, plan, read) and `--mode plan`: RBAi only looks, proposes a
  numbered plan and changes nothing, then asks **Go ahead with this plan?**; Yes switches to "asks before changes" and
  carries it out.
- **`/local rules`** lists the commands you allowed with "don't ask again", by number; `/local rules remove <n>` takes
  one back.
- **PDFs and pictures in the folder are read**: RBAi sends them with your message, as `@` does (PNG, JPEG, WebP and
  GIF are read; TIFF and BMP are sent, and RBAi asks to convert them). A file for the cloud sandbox can be up to 25 MB
  (was 4 MB).
- In Windows' classic console (Windows PowerShell's own window), the welcome says: "For colours and the RBAi logo,
  open this in Terminal."

## 1.2.0-beta.3 (6 Nov 2026)

The third beta of local mode (install it with `RBAI_VERSION=1.2.0-beta.3`): beta.2's fixes, and a running command's
line shows the command again (beta.2 cut it to a few letters, such as "Run python …").

## 1.2.0-beta.2 (6 Nov 2026)

The second beta of local mode (install it with `RBAI_VERSION=1.2.0-beta.2`; 1.1.2 stays what new installs and
`rbai update` get). Fixes from a night of using beta.1 as a scientist would, on Windows:

- On Windows, a command in a folder whose path has `[` or `]` ran in `C:\WINDOWS\System32\WindowsPowerShell\v1.0`
  instead (Windows PowerShell cannot start in such a folder): commands now always run in your folder.
- A PowerShell command's error reached RBAi as XML (`#< CLIXML …`); it is now the text PowerShell shows.
- Reading the end of a large file with an offset is about 4 times faster (a 383 MB FASTQ: 33 s, now 8 s).
- A long command's line no longer leaves copies of itself on the screen, and a command stopped with Esc says
  "stopped" instead of "running".

## 1.2.0-beta.1 (6 Nov 2026)

A beta: install it with the installer and `RBAI_VERSION=1.2.0-beta.1` (or from npm's `next` tag once it is published
there). 1.1.2 stays the version that new installs and `rbai update` get.

New: **RBAi works in your folder.** Started in a folder, `rbai` reads, searches and edits the files there and runs
commands on your computer, asking first, next to every RBAi cloud tool.

- Local tools: read a file (numbered lines, any size, gzip text such as FASTQ.gz and VCF.gz decompressed as it reads),
  list a folder, find files, search their text (no ripgrep needed; hidden and `.gitignore`d files skipped), edit a
  file (its line endings and encoding kept), write a file, run a command (PowerShell on Windows, your bash or zsh on
  macOS and Linux, in the folder, with your own environment), run one in the background and read or stop it, send a
  file to the chat's cloud sandbox, and save a sandbox file into the folder.
- The first time in a folder, one question: Yes, Read only or No (remembered for the folder; in your home folder or a
  drive's root, Enter means No).
- A card before every change and every command, showing exactly what will happen: the command and its folder, or the
  file and a coloured diff. 1 Yes, 2 Yes and don't ask again (for that program and its first argument, or for edits this
  session), 3 No and tell RBAi what to do instead. Esc means No.
- Three modes, Shift+Tab or `--mode`: asks before changes (the default), edits without asking (commands still ask),
  read only.
- Paths are checked by their real path (links and junctions followed): anything outside the folder asks first, and is
  never changed in read mode.
- `/undo` and `/rewind` put files back; `/local log` shows every action and decision (kept in the CLI's own folder,
  never in yours); `/init` has RBAi write an RBAI.md for the folder, and RBAI.md (else AGENTS.md) is RBAi's notes for
  the folder in every turn; `/jobs` lists the commands running on this computer too.
- `rbai ask --local [folder]` for scripts and agents: never a prompt; `--allow edit`, `--allow run` and
  `--allow "run:<program> <first argument>"` say what may change or run, and anything else goes back to RBAi as not
  allowed. stream-json has new `local-call` and `local-result` events.
- `--no-local` (or `/local off`) turns it off; `rbai chat --dir <folder>` picks another folder.

Checks: the render check draws the approval cards, the trust question and the local tool lines in every theme, colour
depth and width from 60 to 160; a new CI step runs the local tools on Linux, macOS and Windows against a real folder
(a `.gz` read, grep, edits that keep CRLF, a timeout that must kill the whole process tree, a background job, and paths
outside the folder refused).

## 1.1.2 (5 Nov 2026)

Fixes:

- The RBAi mark in the welcome box is sharp. In 1.1.1 each of its pixels took the average colour of the logo under it,
  so the edges of the white strands were drawn in in-between shades of blue (42 colours in a 20-pixel mark) and the mark
  looked blurred. Each pixel is now one of the logo's own three colours: the blue disc, the white strands and the
  light-blue strands behind them.

## 1.1.1 (5 Nov 2026)

Fixes:

- The chat's welcome box no longer breaks in colour terminals. In 1.1.0, once signed in, the RBAi mark could fill rows
  with blue, push the account details out of the box and print pieces of colour codes such as `8;2;11;101;201m`
  (seen in Windows Terminal; every colour theme was affected, mono was not). The mark and the box are now drawn as data
  by the terminal UI's own colour code, which writes only codes it can read back.
- The welcome fits the terminal: when an account, project or folder is too long to sit beside the mark, the box shows
  them under the one-line mark instead of cutting them, and the tips go on one line when they fit, else one per line.
- The first-run theme picker fits narrow terminals (60 columns): a sample that does not fit beside its name goes under it.
- Auto theme: the background is read from the terminal's answer in every terminal, Windows included, and the answer is
  always consumed, so it can never reach the theme question or the chat's editor. When the terminal does not say,
  auto now draws the dark theme (1.1.0 drew the terminal's own 16 colours, a look the picker never showed).
- A failed tool's line keeps its `⎿ ` marker when the error is long.

Checks:

- Every push runs a render check in CI: every theme, colour depth and width (60 to 160 columns) through a headless
  terminal, and the built CLI under a real pseudo-terminal on Linux and under ConPTY on Windows. A release is built only
  when it passes.

## 1.1.0 (5 Nov 2026)

For AI agents and IDEs:

- `rbai help reference` prints every command offline: synopsis, arguments, typed flags and defaults, whether it needs a key,
  changes data, spends credits or can wait, what `-o json` returns where the CLI fixes it, its MCP tool, examples, plus the
  global flags, exit codes and environment variables. The package ships it as REFERENCE.md. With `-o json` it points to
  `rbai commands --json`, the same data as JSON.
- `rbai help agents` is now the full guide for AI agents and scripts: sign-in, `-o json --no-input`, what to do on each exit
  code, `rbai ask --output-format stream-json` and its events, exit 8, `--wait`, credits, safety, and worked recipes (a
  literature review, a Galaxy analysis, structure work, Connect, files, projects and `rbai link`).
- `rbai agent-skill` installs the skill with its references (SKILL.md, references/REFERENCE.md, references/recipes.md), adds
  Gemini CLI (`--client gemini`: an extension with the RBAi MCP server), `--print` (every file, with its path, before
  writing) and `--kit <dir>` (the whole agent kit: the Claude Code plugin and marketplace, the Kiro power, the Gemini CLI
  extension, AGENTS.md, Cursor and GitHub Copilot rules, and the MCP Registry entry).
- `rbai commands --json`: each command also says whether it spends credits (`credits`), can wait (`wait`) and what `-o json`
  returns (`returns`, where known).
- The package declares `mcpName` `com.thedreamlabinnovations/rbai`, for the official MCP Registry.

Installing and updating:

- An installer that needs no Node.js: `curl -fsSL https://cli.thedreamlabinnovations.com/install.sh | sh` (macOS, Linux)
  and `irm https://cli.thedreamlabinnovations.com/install.ps1 | iex` (Windows), with standalone builds for 12 targets.
- `rbai update` and the daily update notice work for an installer install too: they read that host's latest version and
  offer the installer again.

Help text:

- The public build's help no longer shows a developer-only local server example; `--api-url` and RBAI_API_URL still work.
  RBAI_API_KEY is described as what it is for users: an API key from Settings → API & MCP → API keys.

## 1.0.0 (5 Nov 2026)

The first public release: the full-screen chat (`rbai`), `rbai ask` for scripts and agents (text, json and stream-json,
exit 8 when RBAi asks a question), commands for projects, sources, literature reviews, chats, Studio, slides, Structure
Studio, files, jobs, figures, the Report Writer and its co-author, Galaxy, Connect and the account, `rbai mcp serve` with
tool groups, `rbai agent-skill`, browser sign-in, proxies, and a daily update notice.
