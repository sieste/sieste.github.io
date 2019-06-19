---
layout: default
---

# Publications

{% for post in site.categories.publication %}
{% capture currentyear %}{{post.date | date: "%Y"}}{% endcapture %}
{% if currentyear != year %}
**{{ currentyear }}**
{% capture year %}{{currentyear}}{% endcapture %} 
{% endif %}
- [{{ post.title }}]({{ post.url }})
{% endfor %}


