---
title: "Position: Current Coding Benchmarks Measure Task Performance, not Coding Capabilities"
authors: '<i>Egor Shibaev, Kudrevskaia Vera, Timur Galimzyanov, Mikhail Evtikhiev, Ana Țerna, Rastislav Rabatin, Timur Kudashev, Timofey Bryksin, Arina Puchkova, Patrik Bartak, Egor Bogomolov, and Sergey Titov</i>'
status: "accepted"
collection: publications
permalink: /publications/2026-07-10-benchmark-generalizability-full
date: 2026-12-06
venue: "<b>NeurIPS'26</b>"
level: "A*"
counter_id: 'C20'
abstract: "<p><b>Abstract</b>. Post-training papers, model cards, and blog posts often treat scores on a small set of coding benchmarks (e.g., SWE-bench and LiveCodeBench) as evidence of broad 'coding capability', both for research artifacts and user-facing systems. We argue that optimization for these benchmarks leads to measuring task-specific performance, creating a meaning gap between measured scores and claims of general coding ability. We examine this gap with a Django-based case study benchmark suite we create.</p><p>Evaluating foundation models and checkpoints post-trained on SWE-bench trajectories, we find that benchmark rankings frequently fail to generalize. Post-trained checkpoints show little cross-task transfer, and SWE-bench optimization yields limited or no gains on our tasks or on LiveCodeBench. Similarly, fine-tuning on individual Django modalities fails to transfer.</p><p>We conclude that a small number of benchmarks is insufficient for evaluating diverse models under benchmark optimization pressure. We encourage the community to use differentiated evaluation—holistic assessment for frontier models, multi-task suites for research, and human-in-the-loop studies for narrow task applications. Finally, we argue for creating a capability taxonomy and sustained benchmark maintenance, rather than one-off benchmark releases. Without reliable evaluation standards, engineers and researchers using LLMs and agents have to rely on insufficient evidence to make research, development, and deployment decisions.</p>"
---