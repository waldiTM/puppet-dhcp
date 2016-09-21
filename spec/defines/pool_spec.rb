require 'spec_helper'

describe 'dhcp::pool' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let :title do 'mypool' end

        let :facts do
          facts.merge({
            :concat_basedir => '/doesnotexist',
          })
        end

        let :pre_condition do
          "class { '::dhcp': interfaces => ['eth0']}"
        end

        describe 'minimal parameters' do
          let :params do {
            :network => '10.0.0.0',
            :mask    => '255.255.255.0',
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              "subnet 10.0.0.0 netmask 255.255.255.0 {",
              "  option subnet-mask 255.255.255.0;",
              "}",
            ])
          }
        end

        describe 'with failover' do
          let :params do {
            :network  => '10.0.0.0',
            :mask     => '255.255.255.0',
            :range    => '10.0.0.10 - 10.0.0.50',
            :failover => '10.1.1.20',
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              'subnet 10.0.0.0 netmask 255.255.255.0 {',
              '  pool',
              '  {',
              '    failover peer "10.1.1.20";',
              '    range 10.0.0.10 - 10.0.0.50;',
              '  }',
              '  option subnet-mask 255.255.255.0;',
              '}',
            ])
          }
        end

        describe 'with empty string range' do
          let :params do {
            :network => '10.0.0.0',
            :mask    => '255.255.255.0',
            :range   => '',
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              "subnet 10.0.0.0 netmask 255.255.255.0 {",
              "  option subnet-mask 255.255.255.0;",
              "}",
            ])
          }
        end

        describe 'with range array' do
          let :params do {
            :network => '10.0.0.0',
            :mask    => '255.255.255.0',
            :range   => ['10.0.0.10 - 10.0.0.50','10.0.0.100 - 10.0.0.150'],
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              'subnet 10.0.0.0 netmask 255.255.255.0 {',
              '  pool',
              '  {',
              '    range 10.0.0.10 - 10.0.0.50;',
              '    range 10.0.0.100 - 10.0.0.150;',
              '  }',
              '  option subnet-mask 255.255.255.0;',
              '}',
            ])
          }
        end

        describe 'with search_domains string' do
          let :params do {
            :network => '10.0.0.0',
            :mask    => '255.255.255.0',
            :search_domains => 'example.org, other.example.org'
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              'subnet 10.0.0.0 netmask 255.255.255.0 {',
              '  option subnet-mask 255.255.255.0;',
              '  option domain-search "example.org", "other.example.org";',
              '}',
            ])
          }
        end

        describe 'with static routes' do
          let :params do {
            :network          => '10.0.0.0',
            :mask             => '255.255.255.0',
            :static_routes    => [
              { 'mask' => '32', 'network' => '128.128.128.128', 'gateway' => '10.0.0.1' },
              { 'mask' => '25', 'network' => '128.128.128.128', 'gateway' => '10.0.0.2' },
              { 'mask' => '24', 'network' => '128.128.128.0',   'gateway' => '10.0.0.3' },
              { 'mask' => '17', 'network' => '128.128.128.0',   'gateway' => '10.0.0.4' },
              { 'mask' => '16', 'network' => '128.128.0.0',     'gateway' => '10.0.0.5' },
              { 'mask' => '9',  'network' => '128.128.0.0',     'gateway' => '10.0.0.6' },
              { 'mask' => '8',  'network' => '128.0.0.0',       'gateway' => '10.0.0.7' },
              { 'mask' => '1',  'network' => '128.0.0.0',       'gateway' => '10.0.0.8' },
              { 'mask' => '0',  'network' => '0.0.0.0',         'gateway' => '10.0.0.9' },
            ],
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              "subnet 10.0.0.0 netmask 255.255.255.0 {",
              "  option subnet-mask 255.255.255.0;",
              "  option rfc3442-classless-static-routes",
              "    32, 128, 128, 128, 128, 10, 0, 0, 1,",
              "    25, 128, 128, 128, 128, 10, 0, 0, 2,",
              "    24, 128, 128, 128, 10, 0, 0, 3,",
              "    17, 128, 128, 128, 10, 0, 0, 4,",
              "    16, 128, 128, 10, 0, 0, 5,",
              "    9, 128, 128, 10, 0, 0, 6,",
              "    8, 128, 10, 0, 0, 7,",
              "    1, 128, 10, 0, 0, 8,",
              "    0, 10, 0, 0, 9;",
              "  option ms-classless-static-routes",
              "    32, 128, 128, 128, 128, 10, 0, 0, 1,",
              "    25, 128, 128, 128, 128, 10, 0, 0, 2,",
              "    24, 128, 128, 128, 10, 0, 0, 3,",
              "    17, 128, 128, 128, 10, 0, 0, 4,",
              "    16, 128, 128, 10, 0, 0, 5,",
              "    9, 128, 128, 10, 0, 0, 6,",
              "    8, 128, 10, 0, 0, 7,",
              "    1, 128, 10, 0, 0, 8,",
              "    0, 10, 0, 0, 9;",
              "}",
            ])
          }
        end

        describe 'full parameters' do
          let :params do {
            :network          => '10.0.0.0',
            :mask             => '255.255.255.0',
            :pool_parameters  => 'allow members of "some-class"',
            :range            => '10.0.0.10 - 10.0.0.50',
            :gateway          => '10.0.0.1',
            :options          => 'ntp-servers 10.0.0.2',
            :parameters       => 'max-lease-time 300',
            :nameservers      => ['10.0.0.2', '10.0.0.4'],
            :pxeserver        => '10.0.0.2',
            :mtu              => 9000,
            :domain_name      => 'example.org',
            :static_routes    => [
              { 'mask' => '24', 'network' => '10.0.1.0', 'gateway' => '10.0.0.2' },
              { 'mask' => '24', 'network' => '10.0.2.0', 'gateway' => '10.0.0.2' },
            ],
            :search_domains   => ['example.org', 'other.example.org'],
          } end

          it {
            verify_concat_fragment_exact_contents(catalogue, 'dhcp.conf+70_mypool.dhcp', [
              "subnet 10.0.0.0 netmask 255.255.255.0 {",
              "  pool",
              "  {",
              "    allow members of \"some-class\";",
              "    range 10.0.0.10 - 10.0.0.50;",
              "  }",
              "  option domain-name \"example.org\";",
              "  option subnet-mask 255.255.255.0;",
              "  option routers 10.0.0.1;",
              "  option rfc3442-classless-static-routes",
              "    24, 10, 0, 1, 10, 0, 0, 2,",
              "    24, 10, 0, 2, 10, 0, 0, 2;",
              "  option ms-classless-static-routes",
              "    24, 10, 0, 1, 10, 0, 0, 2,",
              "    24, 10, 0, 2, 10, 0, 0, 2;",
              "  option ntp-servers 10.0.0.2;",
              "  max-lease-time 300;",
              "  option domain-name-servers 10.0.0.2, 10.0.0.4;",
              "  option domain-search \"example.org\", \"other.example.org\";",
              "  option interface-mtu 9000;",
              "  next-server 10.0.0.2;",
              "}",
            ])
          }
        end
      end
    end
  end
end
