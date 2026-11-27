# A file on your computer: which samples have fewer than 1,000 reads?

The folder holds one small file, `counts.csv`, with read counts for six genes in eight samples:

```csv
gene,S1,S2,S3,S4,S5,S6,S7,S8
ACTB,2450,1980,210,2730,2105,180,2290,2600
GAPDH,1890,1720,160,2010,1840,150,1930,2050
MYC,410,365,40,450,395,35,420,470
TP53,620,580,70,690,610,55,640,700
EGFR,330,290,30,360,320,25,345,380
CDKN1A,505,470,55,540,500,45,515,560
```

In that folder, run:

```sh
rbai ask "Which samples in counts.csv have fewer than 1,000 reads?" --local
```

With `--local` and no `--allow`, RBAi may only read, list and search the files in the folder. It can't change a
file, run a command or upload anything.

## What RBAi did

1. It looked for the file in the folder (`local_glob`, pattern `counts.csv`).
2. It read the file (`local_read`).

It called no other tool, so it added up each sample's counts itself.

## The answer

This is the whole answer.

> Samples **S3** and **S6** have fewer than 1,000 total reads across the listed genes:
>
> - **S3:** 565 reads
> - **S6:** 490 reads

Those totals are correct, and the other six samples have between 5,405 and 6,780 reads.
