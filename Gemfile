source ENV['GEM_SOURCE'] || 'https://rubygems.org'
def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => Regexp.last_match(1),
                     :branch => Regexp.last_match(2),
                     :require => false }].compact
  elsif place =~ %r{^file://(.*)}
    ['>= 0', { :path => File.expand_path(Regexp.last_match(1)),
               :require => false }]
  else
    [place, { :require => false }]
  end
end

group :development, :test do
  # http://stackoverflow.com/questions/30928415/how-to-setup-puppet-rspec-correctly
  gem 'rspec', '~> 2.0' if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'

  gem 'puppetlabs_spec_helper',  :require => false
  if RUBY_VERSION >= '1.9'
    gem 'rake'
  else
    gem 'rake', '< 10.0'
    gem 'highline', '< 1.7'
  end
  if RUBY_VERSION >= '1.9'
    gem 'coveralls', :require => false
  end
  gem 'tins', '< 1.7.0' if RUBY_VERSION >= '1.9' && RUBY_VERSION < '2.0'
  gem 'json', '< 2.0.0' if RUBY_VERSION < '2.0'
  gem 'json_pure', '< 2.0.0' if RUBY_VERSION < '2.0'
  gem 'term-ansicolor', '<= 1.3.2' if RUBY_VERSION >= '1.9' && RUBY_VERSION < '2.0'
  if RUBY_VERSION.split('.').slice(0,2) == ['1','8']
    # for 1.8 we need specific version of mime-types
    gem 'mime-types', '~> 1.25'
  end
end


gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'])

# vim:ft=ruby
