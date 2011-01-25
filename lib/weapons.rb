# load all the *.rb files in the weapons directory
files = File.join(File.dirname(__FILE__), 'weapons', '*.rb')

Dir.glob(files).each { |f| require f }