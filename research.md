---
layout: default
---

# Research

{% for post in site.categories.research-interests %}
**{{ post.title }}**
{{ post.content }}
{% endfor %}




