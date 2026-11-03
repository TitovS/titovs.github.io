---
layout: archive
title: "Work experience"
permalink: /work_experience/
author_profile: true
---

{% include base_path %}

{% assign dated_roles = site.work_experience | where_exp: "role", "role.date_start != nil" | where_exp: "role", "role.date_start != ''" | sort: "date_start" | reverse %}
{% assign missing_dates = site.work_experience | where_exp: "role", "role.date_start == nil" %}
{% assign undated_roles = site.work_experience | where_exp: "role", "role.date_start == ''" | concat: missing_dates %}
{% assign roles = dated_roles | concat: undated_roles %}
{% assign companies = roles | group_by: "company" %}
<nav class="work-navigation" aria-label="Companies">
  {% for company in companies %}
  <a href="#work-company-{{ forloop.index }}">{{ company.name | default: "Earlier experience" | escape }}</a>
  {% endfor %}
</nav>

{% for company in companies %}
<section class="work-company" aria-labelledby="work-company-{{ forloop.index }}">
  <h2 class="work-company__name" id="work-company-{{ forloop.index }}">{{ company.name | default: "Earlier experience" | escape }}</h2>
  <ol class="work-roles">
    {% for role in company.items %}
    <li class="work-roles__item">
      <article class="work-role" aria-labelledby="work-role-{{ role.slug }}">
        <header class="work-role__header">
          <h3 class="work-role__title" id="work-role-{{ role.slug }}"><a href="{{ base_path }}{{ role.url }}">{{ role.title | escape }}</a></h3>
          {% include work-experience-meta.html role=role hide_company=true %}
        </header>
        <div class="work-role__body">
          {% if role.short_description %}
          <div class="work-role__summary">{{ role.short_description | markdownify }}</div>
          {% endif %}
          <div class="work-role__description">{{ role.content | markdownify }}</div>
        </div>
      </article>
    </li>
    {% endfor %}
  </ol>
</section>
{% endfor %}
