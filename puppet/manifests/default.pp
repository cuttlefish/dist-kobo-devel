
$cfg = hiera('kobocat::repo', 'oops')
warning($cfg['branch'])

package { 'software-properties-common':
  ensure => installed,
}

include kobocat
