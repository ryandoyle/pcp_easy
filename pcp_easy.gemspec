Gem::Specification.new do |s|
  s.name    = "pcp_easy"
  s.version = "0.4.1"
  s.summary = "Simple query interface for Performance Co-Pilot"
  s.author  = "Ryan Doyle"

  s.files = Dir.glob("lib/**/*.rb")

  s.add_dependency "ffi"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
  s.add_development_dependency "rake"

end