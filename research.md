---
layout: default
---

# Research

Below is a list of my research interests, which tend to evolve over time. I am
broadly interested in topics on the interface of environmental science,
computation, and statistics. 

Also have a look at my [publications](publications).

{% for post in site.categories.research-interests %}
**{{ post.title }}**
{{ post.content }}
{% endfor %}


