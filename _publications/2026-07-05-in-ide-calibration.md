---
title: "Does In-IDE Calibration of Large Language Models work at Scale?"
authors: '<i>Roham Koohestani, Agnia Sergeyuk, David Gros, Claudio Spiess, Sergey Titov, Prem Devanbu, and Maliheh Izadi</i>'
status: "published"
collection: publications
permalink: /publications/2026-07-05-in-ide-calibration
date: 2026-07-05
venue: "the proceedings of <b>FSE'26</b>"
pdf: 'https://arxiv.org/abs/2510.22614'
data: 'https://zenodo.org/records/17433208'
level: 'A*'
counter_id: 'P3'
abstract: "<p><b>Abstract</b>. The introduction of large language models into integrated development environments (IDEs) is revolutionizing software engineering, yet it poses challenges to the usefulness and reliability of Artificial Intelligence-generated code. Post-hoc calibration of internal model confidences aims to align probabilities with an acceptability measure. Prior work suggests calibration can improve alignment, but at-scale evidence is limited. In this work, we investigate the feasibility of applying calibration of code models to an in-IDE context. We study two aspects of the problem: (1) the technical method for implementing confidence calibration and improving the reliability of code generation models, and (2) the human-centered design principles for effectively communicating reliability signal to developers. First, we develop a scalable and flexible calibration framework which can be used to obtain calibration weights for open-source models using any dataset, and evaluate whether calibrators improve the alignment between model confidence and developer acceptance behavior. Through a large-scale analysis of over 24 million real-world developer interactions across multiple programming languages, we find that a general, post-hoc calibration model based on Platt-scaling does not, on average, improve the reliability of model confidence signals. We also find that while dynamically personalizing calibration to individual users can be effective, its effectiveness is highly dependent on the volume of user interaction data. Second, we conduct a multi-phase design study with 3 expert designers and 153 professional developers, combining scenario-based design, semi-structured interviews, and survey validation, revealing a clear preference for presenting reliability signals via non-numerical, color-coded indicators within the in-editor code generation workflow.</p>"
---