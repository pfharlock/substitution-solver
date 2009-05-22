$dictionary = Hash.new(0)											# The dictionary of tetragraph frequencies

File.open("english.dic") do |f|										# Open the saved
	$dictionary = Marshal.load(f)									# And load this information into our dictionary
end

array = $dictionary.to_a.sort {|x, y| x[1] <=> y[1]}

x = 0
array.each do |tetragraph, freq|
	puts "#{x+=1}, #{tetragraph}, #{freq}"
end
