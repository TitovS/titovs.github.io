---
layout: archive
title: "Work experience"
permalink: /work_experience/
author_profile: true
---

{% include base_path %}

{% assign roles = site.work_experience | sort: "order" | reverse %}
{% for post in roles %}
{% include archive-single.html %}
{% endfor %}
