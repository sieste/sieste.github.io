---
layout: plain
---

# All posts:

{% for post in site.posts %}
{% capture currentyear %}{{post.date | date: "%B %Y"}}{% endcapture %}
{% if currentyear != year %}
**{{ currentyear }}**
{% capture year %}{{currentyear}}{% endcapture %} 
{% endif %}
* {{post.date | date: "%B %d"}}: [{{ post.title }}]({{ post.url }})
{% endfor %}

