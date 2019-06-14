---
layout: default
---

# Research

{% for post in site.categories.research-interests %}
**{{ post.title }}**
{{ post.content }}
{% endfor %}


## Publications

{% for post in site.categories.publication %}
{% capture currentyear %}{{post.date | date: "%Y"}}{% endcapture %}
{% if currentyear != year %}
**{{ currentyear }}**
{% capture year %}{{currentyear}}{% endcapture %} 
{% endif %}
- [{{ post.title }}]({{ post.url }})
{% endfor %}


