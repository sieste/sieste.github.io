---
title: Home 
layout: default
---


# List of posts

{% for post in site.posts %}
[{{ post.title }}]({{ post.url }})
{% endfor %}
