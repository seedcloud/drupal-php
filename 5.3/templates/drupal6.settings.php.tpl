<?php
/**
 * @file
 * Seedcloud environment configuration for Drupal 7.
 */

$seedcloud['base_url'] = '{{ getenv "SEEDCLOUD_HOST_PRIMARY" "" }}';

$seedcloud['site'] = '{{ getenv "DRUPAL_SITE" }}';
$seedcloud['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';

$seedcloud['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$seedcloud['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$seedcloud['db']['username'] = '{{ getenv "DB_USER" "" }}';
$seedcloud['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$seedcloud['db']['driver'] = '{{ getenv "DB_DRIVER" "mysqli" }}';

$seedcloud['varnish']['host'] = '{{ getenv "VARNISH_HOST" "" }}';
$seedcloud['varnish']['terminal_port'] = '{{ getenv "VARNISH_SERVICE_PORT_6082" "6082" }}';
$seedcloud['varnish']['secret'] = '{{ getenv "VARNISH_SECRET" "" }}';
$seedcloud['varnish']['version'] = '{{ getenv "VARNISH_VERSION" "4" }}';

$seedcloud['memcached']['host'] = '{{ getenv "MEMCACHED_HOST" "" }}';
$seedcloud['memcached']['port'] = '{{ getenv "MEMCACHED_SERVICE_PORT" "11211" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (!isset($base_url) && !empty($seedcloud['base_url'])) {
  $base_url = $seedcloud['base_url'];
}

if (!isset($update_free_access)) {
  $update_free_access = FALSE;
}

if (empty($drupal_hash_salt)) {
  $drupal_hash_salt = $seedcloud['hash_salt'];
}

if (!isset($conf['404_fast_html'])) {
  $conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
  $conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
  $conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
}

if (!empty($seedcloud['db']['host'])) {
  $args = array(
    'host' => $seedcloud['db']['host'],
    'database' => $seedcloud['db']['name'],
    'username' => $seedcloud['db']['username'],
    'password' => $seedcloud['db']['password'],
    'driver' => $seedcloud['db']['driver'],
  );

  $db_url = strtr('driver://username:password@host/database', $args);
}

$conf['file_directory_path'] = "sites/{$seedcloud['site']}/files";
$conf['file_directory_temp'] = '/tmp';

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  $site_mods_dir = "sites/{$seedcloud['site']}/modules";
  $contrib_path = is_dir('sites/all/modules/contrib') ? 'sites/all/modules/contrib' : 'sites/all/modules';
  $contrib_path_site = is_dir("$site_mods_dir/contrib") ? "$site_mods_dir/contrib" : $site_mods_dir;

  $varnish_module_exists = file_exists("$contrib_path/varnish") || file_exists("$contrib_path_site/varnish");

  if (!empty($seedcloud['varnish']['host']) && $varnish_module_exists) {
    $conf['varnish_version'] = $seedcloud['varnish']['version'];
    $conf['varnish_control_terminal'] = $seedcloud['varnish']['host'] . ':' . $seedcloud['varnish']['terminal_port'];
    $conf['varnish_control_key'] = $seedcloud['varnish']['secret'];
  }

  $memcache_module_path = NULL;

  if (file_exists("$contrib_path/memcache")) {
    $memcache_module_path = "$contrib_path/memcache";
  } elseif (file_exists("$contrib_path_site/memcache")) {
    $memcache_module_path = "$contrib_path_site/memcache";
  }

  if (!empty($seedcloud['memcached']['host']) && $memcache_module_path) {
    $conf['memcache_extension'] = 'memcached';
    $conf['cache_inc'] = "$memcache_module_path/memcache.inc";
    $conf['memcache_servers'] = array($seedcloud['memcached']['host'] . ':' . $seedcloud['memcached']['port'] => 'default');
    $conf['memcache_key_prefix'] = substr($drupal_hash_salt, -10);
    $conf['memcache_bins'] = array(
      'cache' => 'default',
      'cache_update' => 'database',
      'cache_form' => 'database',
    );
  }
}

ini_set('arg_separator.output',     '&amp;');
ini_set('magic_quotes_runtime',     0);
ini_set('magic_quotes_sybase',      0);
ini_set('session.cache_expire',     200000);
ini_set('session.cache_limiter',    'none');
ini_set('session.cookie_lifetime',  2000000);
ini_set('session.gc_maxlifetime',   200000);
ini_set('session.save_handler',     'user');
ini_set('session.use_cookies',      1);
ini_set('session.use_only_cookies', 1);
ini_set('session.use_trans_sid',    0);
ini_set('url_rewriter.tags',        '');
ini_set('pcre.backtrack_limit', 200000);
ini_set('pcre.recursion_limit', 200000);
