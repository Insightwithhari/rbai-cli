# A reagent: who has a validated anti-GPX4 antibody for mouse tissue?

```sh
rbai connect ask "Who distributes a validated anti-GPX4 antibody for mouse tissue?"
```

`rbai connect ask` asks RBAi in Connect, the part of RBAi that looks for materials, services, collaborators and
papers. It can draft an email, but it never sends one.

## What RBAi did

The CLI's progress line showed 8 tool calls in 4 steps. `rbai connect show` doesn't print a Connect answer's tool
calls, so their names aren't listed here. The answer links the product pages it relied on, from Proteintech, Thermo
Fisher and Cell Signaling Technology.

## The answer

This is the whole answer.

> **Proteintech** is the clearest match for an anti-GPX4 antibody tested on mouse tissue:
>
> - **82949-1-RR** — rabbit recombinant antibody; Proteintech lists IHC and mouse reactivity, and shows positive IHC
>   staining in **mouse testis tissue**.
>   [Product page](https://www.ptglab.com/products/GPX4-Antibody-82949-1-RR.htm)
> - **67763-1-Ig** — mouse monoclonal; Proteintech also reports positive IHC in **mouse testis tissue**. It is listed
>   by [Proteintech](https://www.ptglab.com/Products/GPX4-Antibody-67763-1-Ig.htm) and
>   [Thermo Fisher](https://www.thermofisher.com/antibody/primary/target/GPX4).
>
> For IHC on mouse tissue, **82949-1-RR** may be a convenient first option because it is a rabbit antibody. The
> validation examples cited are for mouse testis, so performance in a different tissue or assay should be checked.
> CST’s **59735** page specifically says it is *not recommended* for immunohistochemical analysis of mouse tissues.
> [CST product page](https://www.cellsignal.com/products/primary-antibodies/gpx4-e5y8k-rabbit-monoclonal-antibody/59735)
>
> If you tell me the mouse tissue and assay (IHC, IF, or Western blot), I can narrow this down further.
