---
layout: archive
title: "Work experience"
permalink: /work_experience/
author_profile: true
---

{% include base_path %}

{% assign dated_roles = site.work_experience | where_exp: "role", "role.date_start != nil and role.date_start != ''" | sort: "date_start" | reverse %}
{% assign undated_roles = site.work_experience | where_exp: "role", "role.date_start == nil or role.date_start == ''" %}
{% assign roles = dated_roles | concat: undated_roles %}
{% assign companies = roles | group_by: "company" %}
{% for company in companies %}
<section class="work-company" aria-labelledby="work-company-{{ forloop.index }}">
  <h2 class="work-company__name" id="work-company-{{ forloop.index }}">{{ company.name | default: "Earlier experience" | escape }}</h2>
  <ol class="work-timeline">
    {% for role in company.items %}
    <li class="work-timeline__role">
      <article>
        <h3 class="work-timeline__title"><a href="{{ base_path }}{{ role.url }}">{{ role.title | escape }}</a></h3>
        {% include work-experience-meta.html role=role hide_company=true %}
        {% if role.short_description %}
        <div class="work-timeline__summary">{{ role.short_description | markdownify }}</div>
        {% endif %}
      </article>
    </li>
    {% endfor %}
  </ol>
</section>
{% endfor %}
