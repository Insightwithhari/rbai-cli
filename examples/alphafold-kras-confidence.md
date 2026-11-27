# A predicted structure: how confident is AlphaFold about KRAS?

```sh
rbai ask "How confident is the AlphaFold model of human KRAS, and which regions are least certain?"
```

## What RBAi did

1. It found human KRAS in UniProt (`uniprot_entry`, gene KRAS, organism 9606), which gave the accession P01116 and
   its sequence.
2. It read the AlphaFold model and its per-residue confidence for residues 1 to 189 (`alphafold`, accession P01116).

## The answer

This is the whole answer.

> The **AlphaFold DB model for human KRAS (UniProt P01116; 189 residues)** has **high overall local confidence**:
> mean pLDDT **91.5**. About **78%** of residues are in the “very high” category (>90), and about **93%** are at
> least “confident” (≥70).
>
> | Region (UniProt numbering) | Model confidence | Takeaway |
> |---|---:|---|
> | **2–28, 38–58, 71–169** | pLDDT >90 throughout | Most of the model is very high confidence |
> | **29–37** | 77.8–84.6 | Lower-confidence patch |
> | **59–70** | 73.1–89.8 | Another moderate-confidence patch |
> | **170–175** | 71.3–88.7 | Confidence falls toward the C-terminus |
> | **176–189** | 45.2–64.3 | **Least certain region**; the terminal tail is low or very low confidence |
>
> The clearest caution is the **C-terminal end, especially residues 178–182**, which are very low confidence (<50)
> except residue 181. The N-terminal residue 1 is also less certain than the core (pLDDT 85.3). The
> moderate-confidence patches around **29–37** and **59–70** include regions often described as KRAS switch loops,
> which can be flexible; treat their exact modeled conformations cautiously.
>
> These are AlphaFold’s **local-structure confidence scores**, not experimental validation or a guarantee that KRAS
> adopts one fixed conformation. Source: **AlphaFold DB**, model **AF-P01116-F1**, version 6; sequence identity and
> length cross-checked against **UniProtKB**.

pLDDT is AlphaFold's confidence score for each residue, from 0 to 100.
