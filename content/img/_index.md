---
title: "Images"
---

<style>
  .image-gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 10px;
    list-style: none;
    padding: 0;
  }
  .image-gallery img {
    width: 100%;
    height: auto;
    border-radius: 5px;
  }
</style>

<ul class="image-gallery">
  {{ range .Resources.Match "*.png" }}
    <li>
      <img src="{{ .RelPermalink }}" alt="{{ .Name }}" width="200">
      <p>{{ .Name }}</p>
    </li>
  {{ end }}
</ul>
