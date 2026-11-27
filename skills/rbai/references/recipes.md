# Recipes: life-science work with rbai

Each recipe is a complete run with `-o json --no-input`. Replace the `<…>` values with what the previous
step returned. The commands that spend credits are marked.

## Recipe 1: a literature review, from question to Markdown

```sh
# 1. Start it (spends credits; low, medium, high or max: deeper reads more papers and costs more).
#    --idempotency-key makes a retry after a timeout return the same review instead of a second one.
rbai review create "CRISPR off-target effects in primary human T cells" \
  --level medium --idempotency-key tcell-offtarget-1 -o json --no-input
# → {"id": "<review id>", "status": "started"}   ("queued" when every review slot is busy: it starts later)

# 2. Follow it. Either block until it ends (exit 0 completed; exit 1 failed or cancelled) ...
rbai review watch <review id> --no-input
#    ... or poll every minute or so:
rbai review show <review id> -o json --query status

# 3. Read the result.
rbai review export <review id> --dest review.md          # the review text, with its numbered references
rbai review export <review id> --format json --dest review.json   # the whole record (papers, query, metadata)

# 4. Ask about its papers (spends credits).
rbai review ask <review id> "Which of these papers used primary human T cells rather than cell lines?" -o json --no-input
```

Tell the user where the review is in the web app (Literature reviews), and what it cost if you know.

## Recipe 2: a Galaxy analysis

Galaxy runs on the Galaxy server the user chose (usegalaxy.org, usegalaxy.eu, …) with their own Galaxy API key.

```sh
# 1. Is a Galaxy key saved? (previews only, never the key)
rbai galaxy key list -o json
#    None: ask the user to run `rbai galaxy key set --server https://usegalaxy.eu` in their terminal
#    (it asks for the key), or to save it in the web app under Settings → Galaxy.
rbai galaxy test -o json                       # the key works against Galaxy

# 2. Look at the data.
rbai galaxy histories -o json
rbai galaxy datasets <history id> -o json

# 3. Give the Galaxy agent the task (spends credits). It picks the tools and runs them on Galaxy.
rbai galaxy ask "Run FastQC on the two FASTQ files in my newest history, then MultiQC on the reports" \
  --output-format stream-json --no-input

# 4. Jobs RBAi tracks for the user, and the results.
rbai galaxy jobs -o json
rbai galaxy download <history id> <dataset id> --dest multiqc_report.html
```

The Galaxy agent stops and says so when data it needs cannot be found; it never makes data up. Report its
answer as it wrote it, and read the outputs (step 4) before quoting numbers.

## Recipe 3: protein structure work (Structure Studio)

```sh
# 1. Have the assistant show the structure (spends credits).
rbai ask "Show the crystal structure of MDM2 bound to the p53 peptide, PDB 1YCR" --output-format json --no-input
# → sessionId, and in toolCalls a show_structure call: its toolCallId is the structure's anchor.

# 2. A studio exists once the structure was opened in the web app's 3D viewer. If the next command says
#    there is no studio yet, ask the user to open the conversation in the web app and open the structure.
rbai structure show <sessionId> <toolCallId> -o json              # versions, Edit with AI turns, figures

# 3. Edit with AI (spends credits): change, analyse or render with PyMOL.
rbai structure ask <sessionId> <toolCallId> "Colour the residues within 5 Å of the peptide and render a figure" -o json --no-input

# 4. Download a version (the file PyMOL saved).
rbai structure download <sessionId> <toolCallId> 2 --dest 1ycr-v2.pdb
```

## Recipe 4: Connect (materials, services, collaborators)

```sh
# 1. Ask Connect (spends credits). It searches suppliers, registries, papers and labs, and can draft emails.
rbai connect ask "Find a validated anti-GPX4 antibody for mouse tissue and draft an email to the lab that published it" \
  --output-format json --no-input

# 2. Read the conversation, including any draft.
rbai connect show -o json

# 3. A free search of RBAi's researcher directory.
rbai researcher search CRISPR base editing -o json

# 4. The labs that used a reagent or method, with each lab's sentence (a Connect message; uses credits).
#    It reads up to --budget credits (40 by default); with no person at the terminal it stops there and
#    its JSON says status "budget" and ask. Read on with the same item and country and --resume.
rbai researcher labs cryo-EM --country DE --budget 20 -o json
rbai researcher labs cryo-EM --country DE --resume --budget 20 -o json
```

Connect sends nothing from the CLI. Tell the user that a draft is waiting in Connect in the web app, where
they read it and choose to send it. `rbai request list -o json` shows requests they already sent.

## Recipe 5: files and downloads

```sh
# Send files with a question.
rbai ask "Summarise the differential expression results" --attach deseq2_results.csv --output-format json --no-input

# A file the assistant's code sandbox saved (the answer's saved-file link, or a `file` event).
rbai session file <sessionId> volcano_plot.png --dest figures/volcano_plot.png

# Edit with AI for a figure an answer drew in Python (spends credits; minutes at max effort, no time limit).
# The new figure is saved under its "-edit" name with its program beside it (.py); --code starts the next edit from it.
rbai plot edit --session <sessionId> --figure volcano_plot.png "Label the 10 most significant genes" -o json --no-input

# Any file the answer links to (`links[].href`): a Word or Excel file RBAi built, a sandbox file,
# a file or folder on a project's computer (a big file comes through the server's copy, with progress).
rbai session save "/api/chat-files/stored/<sessionId>/<sha256>.docx/report.docx" --dest report.docx
rbai session save "/api/chat-files/computer/<sessionId>?path=/mnt/data/run" -o json   # a folder: its files

# Outputs of background jobs.
rbai job list -o json
rbai job show <job id> -o json
rbai job download <job id> 0 --dest results.csv

# The PDF library, and a whole conversation.
rbai library list -o json
rbai library download <document id> --dest paper.pdf
rbai session export <sessionId> --format md --dest conversation.md
```

`--dest -` writes a download to stdout. Choose a `--dest` path that does not hold a file the user wants to keep.

## Recipe 6: projects, sources and rbai link

A project holds sources (papers, PDFs, web pages, notes) that the assistant reads and cites as S1, S2, ….

```sh
# 1. Create a project and link this folder to it: every rbai command run here then uses it.
rbai project create "MDM2 inhibitors" -o json --no-input          # → the project, with its id
rbai link <project id> -o json --no-input                         # writes .rbai/project.json (no key in it)

# 2. Add sources (in a linked folder the project argument can be left out).
rbai source add --paper 10.1038/nature12373 -o json --no-input    # a DOI, PMID or arXiv id
rbai source add --file ./nutlin-review.pdf --wait -o json --no-input
rbai source list -o json

# 3. Ask within the project's sources (spends credits); the answer cites them.
rbai ask "What do my sources say about nutlin-3a resistance mechanisms?" --output-format json --no-input

# 4. A Studio output from the sources (spends credits), e.g. an evidence table.
rbai studio create <project id> --kind evidence_table --wait -o json --no-input
rbai studio show <project id> <output id> --text > evidence-table.md
```

`rbai unlink` removes the folder's link. `.rbai/project.json` holds only the project's id and title and the
API address, so it can be committed with the folder.
