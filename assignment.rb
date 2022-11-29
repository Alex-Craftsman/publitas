require './feed-parser'

if File.file?(ARGV.first) then
  FeedParser.new(ARGV.first).call
else
  raise "File does not exists"
end