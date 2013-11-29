source 'https://rubygems.org'

group :development, :test do                                                    
  if RUBY_VERSION.split('.').slice(0,2) == ['1','8']
    # for 1.8 we need specific version of mime-types
    gem 'mime-types', '~> 1.25'
  end
  gem 'rake' 
  gem 'puppetlabs_spec_helper',  :require => false                              
  gem 'coveralls', :require => false
end                                                                             

if puppetversion = ENV['PUPPET_GEM_VERSION']                                    
  gem 'puppet', puppetversion, :require => false                                
else                                                                            
  gem 'puppet', :require => false                                               
end                                                                             
#
# vim:ft=ruby                                                                   
