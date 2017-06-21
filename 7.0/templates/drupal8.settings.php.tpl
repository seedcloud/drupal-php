<?php
/**
 * @file
 * Wodby environment configuration for Drupal 8.
 */

{{ $hosts := split (getenv "SEEDCLOUD_HOSTS" "" ) "/" }}{{ range $hosts }}
$seedcloud['hosts'][] = '{{ . }}';
{{ end }}

$seedcloud['files_dir'] = '{{ getenv "SEEDCLOUD_DIR_FILES" }}';
$seedcloud['site'] = '{{ getenv "DRUPAL_SITE" }}';
$seedcloud['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';
$seedcloud['sync_salt'] = '{{ getenv "DRUPAL_FILES_SYNC_SALT" "" }}';

$seedcloud['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$seedcloud['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$seedcloud['db']['username'] = '{{ getenv "DB_USER" "" }}';
$seedcloud['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$seedcloud['db']['driver'] = '{{ getenv "DB_DRIVER" "mysql" }}';

$seedcloud['redis']['host'] = '{{ getenv "REDIS_HOST" "" }}';
$seedcloud['redis']['port'] = '{{ getenv "REDIS_SERVICE_PORT" "6379" }}';
$seedcloud['redis']['password'] = '{{ getenv "REDIS_PASSWORD" "" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (empty($settings['container_yamls'])) {
  $settings['container_yamls'][] = "sites/{$seedcloud['site']}/services.yml";
}

if (!array_key_exists('update_free_access', $settings)) {
  $settings['update_free_access'] = FALSE;
}

if (empty($settings['hash_salt'])) {
  $settings['hash_salt'] = $seedcloud['hash_salt'];
}

if (!array_key_exists('file_scan_ignore_directories', $settings)) {
  $settings['file_scan_ignore_directories'] = [
    'node_modules',
    'bower_components',
  ];
}

if (!empty($seedcloud['db']['host'])) {
  if (!isset($databases['default']['default'])) {
    $databases['default']['default'] = [];
  }

  $databases['default']['default'] = array_merge(
    $databases['default']['default'],
    [
      'host' => $seedcloud['db']['host'],
      'database' => $seedcloud['db']['name'],
      'username' => $seedcloud['db']['username'],
      'password' => $seedcloud['db']['password'],
      'driver' => $seedcloud['db']['driver'],
    ]
  );
}

$settings['file_public_path'] = "sites/{$seedcloud['site']}/files";
$settings['file_private_path'] = $seedcloud['files_dir'] . '/private';
$settings['file_temporary_path'] = '/tmp';

$config_directories['sync'] = $seedcloud['files_dir'] . '/config/sync_' . $seedcloud['sync_salt'];

if (!empty($seedcloud['hosts'])) {
  foreach ($seedcloud['hosts'] as $host) {
    $settings['trusted_host_patterns'][] = '^' . str_replace('.', '\.', $host) . '$';
  }
}

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  $site_mods_dir = "sites/{$seedcloud['site']}/modules";
  $contrib_path = is_dir('modules/contrib') ? 'modules/contrib' : 'modules';
  $contrib_path_site = is_dir("$site_mods_dir/contrib") ? "$site_mods_dir/contrib" : $site_mods_dir;

  $redis_module_path = NULL;

  if (file_exists("$contrib_path/redis")) {
    $redis_module_path = "$contrib_path/redis";
  } elseif (file_exists("$contrib_path_site/redis")) {
    $redis_module_path = "$contrib_path_site/redis";
  }

  if (!empty($seedcloud['redis']['host']) && $redis_module_path) {
    $settings['redis.connection']['host'] = $seedcloud['redis']['host'];
    $settings['redis.connection']['port'] = $seedcloud['redis']['port'];
    $settings['redis.connection']['password'] = $seedcloud['redis']['password'];
    $settings['redis.connection']['base'] = 0;
    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['cache']['default'] = 'cache.backend.redis';
    $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

    $settings['container_yamls'][] = "$redis_module_path/example.services.yml";
  }
}
