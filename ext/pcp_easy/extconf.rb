require 'mkmf'
extension_name = 'pcp_easy'
asplode('pcp') unless find_library('pcp', 'pmNewContext')
dir_config(extension_name)
create_makefile(extension_name)