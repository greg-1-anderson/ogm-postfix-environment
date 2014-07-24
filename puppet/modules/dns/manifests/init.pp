class dns (
  $zones = [],
  $a = [],
  $cname = [],
  $mx = [],
  $txt = [],
) {
  # include dns::install
  # include dns::config
  # include dns::service

  if !empty($zones) {
    include dns::server

    create_resources('dns::zone',$zones)
    if !empty($a) {
      create_resources('dns::record::a',$a)
    }
    if !empty($cname) {
      create_resources('dns::record::cname',$cname)
    }
    if !empty($mx) {
      create_resources('dns::record::mx',$mx)
    }
    if !empty($txt) {
      create_resources('dns::record::txt',$txt)
    }
  }
}
