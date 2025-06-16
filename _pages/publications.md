---
layout: archive
title: "Publications"
permalink: /publications/
author_profile: true
---

{% include base_path %}

<p style="margin-bottom: -10px; padding-bottom: 0; color: #888888"><i><b>C</b> — Conference papers. <b>P</b> — Pre-prints.</i></p>

{% for post in site.publications reversed %}
{% include archive-single.html %}
{% endfor %}
