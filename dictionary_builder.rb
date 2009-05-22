#! /usr/bin/env ruby

hash = Hash.new(0)

$stdin.each do |line|
	line.gsub!(/[^a-zA-Z]/, "").upcase!
	for x in 0...line.length-4
		hash[line[x...x+4]] += 1
	end
end

#puts hash.to_a.sort {|x, y| x[1] <=> y[1]}
	
File.open("english.dic", "w+") do |f|
	Marshal.dump(hash, f)
end
