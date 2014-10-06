
$cfg = hiera('kobocat::repo', 'oops')
warning($cfg['branch'])
include kobocat
