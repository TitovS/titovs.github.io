---
title: "LibEvoBench: Probing Temporal Knowledge Stratification in Code Generation Models"
authors: '<i>Daniele Cipollone, Sergey Titov, Maliheh Izadi, Egor Bogomolov, and Arie van Deursen</i>'
status: "published"
collection: publications
permalink: /publications/2026-07-10-libevobench
date: 2026-07-10
venue: "the proceedings of <b>DL4Code'26</b>"
level: "Workshop"
paperurl: "https://openreview.net/pdf?id=T9Ud4QTeNF"
pdf: 'https://arxiv.org/abs/2606.25402'
data: 'https://zenodo.org/records/20066456'
counter_id: 'C19'
abstract: "<p><b>Abstract</b>. Large software projects often depend on older versions of libraries, even as APIs continue to evolve across releases. This creates a challenge for LLMs: they must maintain knowledge of multiple API versions, not merely the latest or most common one. However, current LLMs are trained on temporally mixed corpora and lack explicit mechanisms for such version-specific reasoning, leading to anachronistic errors - calling APIs as they exist in a different library version. To systematically evaluate this phenomenon, we introduce LibEvoBench, a multi-task benchmark spanning multiple versions of widely used Python libraries, along with a new metric, the Software Evolution Understanding Score (SEUS), to measure models' consistency when working with evolving APIs. Our results show that state-of-the-art models are largely version-oblivious: performance degrades for evolving APIs, while for stable APIs it remains the same across versions. Moreover, simply specifying the target version provides no benefit, while relevant documentation significantly boosts models' accuracy. These findings highlight a systematic limitation of current training paradigms and motivate new approaches for temporally grounded knowledge in code generation.</p>"
---