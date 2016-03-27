Gem::Specification.new do |s|
  s.name    = "pcp_easy"
  s.version = "0.0.1"
  s.summary = "Simple query interface for Performance Co-Pilot"
  s.author  = "Ryan Doyle"

  s.files = Dir.glob("ext/**/*.{c,rb}") +
            Dir.glob("lib/**/*.rb")

  s.extensions << "ext/pcp_easy/extconf.rb"

  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec"
end