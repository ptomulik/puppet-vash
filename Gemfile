source 'https://rubygems.org'

group :development, :test do                                                    
  gem 'rake' 
  gem 'puppetlabs_spec_helper',  :require => false                              
end                                                                             

if puppetversion = ENV['PUPPET_GEM_VERSION']                                    
  gem 'puppet', puppetversion, :require => false                                
else                                                                            
  gem 'puppet', :require => false                                               
end                                                                             
#
# vim:ft=ruby                                                                   
