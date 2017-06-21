<?php

$site = {{ getenv "DRUPAL_SITE" "default" }};

{{ $hosts := split (getenv "SEEDCLOUD_HOSTS") "/" }}
{{ range $hosts }}
$sites['{{ . }}'] = $site;
{{ end }}
