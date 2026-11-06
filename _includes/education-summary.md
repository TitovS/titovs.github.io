{% assign bachelors = site.data.education.bachelors %}{% assign masters = site.data.education.masters %}{% assign phd = site.data.education.phd %}I obtained a {{ bachelors.degree }} in {{ bachelors.subject }} from [{{ bachelors.institution }}]({{ bachelors.url }}) in {{ bachelors.date_finish }} and a {{ masters.degree }} in {{ masters.subject }} from the same university in {{ masters.date_finish }}.
From {{ phd.date_start }} to {{ phd.date_finish }}, I pursued a {{ phd.degree }} in {{ phd.subject }} at the [{{ phd.institution }}]({{ phd.url }}), focusing on {{ phd.focus }}{% unless phd.completed %}, however, I did not finish it{% endunless %}.

{% assign education_keys = "masters,bachelors,phd" | split: "," %}
{% capture thesis_titles %}
{% for education_key in education_keys %}
{% assign degree = site.data.education[education_key] %}
{% if degree.thesis.title and degree.thesis.title != "" %}
<li><strong>{{ degree.degree | escape }}{% if degree.completed == false %} (not completed){% endif %}:</strong> “{{ degree.thesis.title | escape }}”</li>
{% endif %}
{% endfor %}
{% endcapture %}
{% assign thesis_titles = thesis_titles | strip %}
{% if thesis_titles != empty %}
<details>
  <summary>Thesis titles</summary>
  <ul>{{ thesis_titles }}</ul>
</details>
{% endif %}
