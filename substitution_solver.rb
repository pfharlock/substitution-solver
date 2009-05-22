#!/usr/bin/env ruby

$iteration = 0														# To record how many iterations the programs
																	#  had to churn through

ciphertext = String.new

$stdin.each do |line|												# Grab the input from the standard input
	ciphertext << line
end

ciphertext.gsub!(/[^a-zA-Z]/, "").upcase!							# get rid of any non-alphabetic characters

key = Hash.new														# Create a hash that will represent the translation key
	
$dictionary = Hash.new(0)											# The dictionary of tetragraph frequencies
File.open("english.dic") do |f|										# Open the saved tetragraph information
	$dictionary = Marshal.load(f)									# And load this information into our dictionary
end
	
def score(string)													# This function will score a string against the tetragraph statistics
	$iteration += 1													# Increment the iteration count as this is probably the most fundamental loop to the program
	tally = 0														# Set a counter to 0
	0.upto(string.length-4) do |x|									# Iterate through the string
		tally += Math.log(($dictionary[string[x...x+4]].to_i)+1)	# tally up the tetragraph frequencies after applying log to each one (the log is where the magic happens)
	end
	return tally													# and return our grand total when we're finished adding it all up
end
	
def small_adj!(key)													# this function makes small random adjustments to the key when we've hill climbed our way into a dead end
	for i in 0...rand(5)											# pick a random number of changes to make
		j = rand(26)												# now pick two random letters in the alphabet to swap
		k = rand(26)
		if j != k													# if the random letters aren't equal 
			temp = key[(j+65).chr]									#  then go ahead and swap them
			key[(j+65).chr] = key[(k+65).chr]
			key[(k+65).chr] = temp
		end
	end
end
	
def plaintext(ciphertext, key)										# This function will return the decoded ciphertext using a given key to do the decoding
	return_string = String.new										# create a return string

	for x in 0...ciphertext.length									# loop through the ciphertext
		return_string << key[ciphertext[x].chr]						# swap the letters out using the key and build up the return string
	end
	return return_string											# return the answer
end
	
def randomize!(key)													# completely randomize the key, ie start over from scratch
	array = Array.new												# create an array of letters to pick from

	for x in 0...26
		array[x] = (x+65).chr										# populate the array with characters
	end
		
	for x in 0...26													# now loop through the array taking a letter out
		y = rand(array.length)										# one at a time randomely and adding it to the key
		key[(x+65).chr] = array[y]
		array.delete_at(y)
	end
end
	
print "best overall = ", score(ciphertext), " : best score = ", score(ciphertext), "\n"	#print the original ciphertext
puts ciphertext.gsub(/(.....)/, '\1 ')
	
randomize!(key)														# randomize the key
	
best_score=score(ciphertext);										# set the best score to the score of the ciphertext
best_overall=best_score-1;											# set the best overall score to the best score -1
num_small_adjusts=0;												# set the number of small adjustments to 0

loop do																# loop forever
	best_adj = best_score											# set the best adjustment to the current best score

	for i in 0...26													# loop through all possible "trivial" letter replacements
		for j in i+1...26											# in the key looking for the best swap.  This in effect is
			test_key = key.dup										# the so called "Hill Climbing" part of our program
			temp = test_key[(i+65).chr]
			test_key[(i+65).chr] = test_key[(j+65).chr]
			test_key[(j+65).chr] = temp
			sc = score(plaintext(ciphertext, test_key))				# score the change we've made
			if sc > best_adj										# if it's better than any so far
				best_adj=sc											# then record the change so we can apply it later if it
				best_i = i											# turns out to be the best one
				best_j = j
			end
		end
	end
	
	if best_adj > best_score										# if we found an adjustment that improves the best score
		temp = key[(best_i+65).chr]									# then apply that adjustment to the key
		key[(best_i+65).chr] = key[(best_j+65).chr]
		key[(best_j+65).chr] = temp
		best_score = best_adj
		if best_score > best_overall								# if that adjustment is the best overall
			num_small_adjusts = 0									# then reset the number of small adjusts counter
			best_overall = best_score								# set this new score as the best overall
	        print "best overall = ", best_overall, " : best score = ", best_score, " : iteration = #{$iteration}\n"
			puts plaintext(ciphertext, key).gsub(/(.....)/, '\1 ')	# and print our new found best overall value
		end
	else															# otherwise none of the adjustments raised are score
		if num_small_adjusts < 10									# so make a small random adjustment to the key
			small_adj!(key)											#  as long as we haven't already made to many small adjustments
			num_small_adjusts += 1									# increment the number of small adjustments
		else														# otherwise we've made to many small adjustments, we're
			randomize!(key)											#  probably not getting anywhere and need to start looking
			num_small_adjusts = 0									#  somplace else, randomize the key and start climbing the 
		end															#  hill again
		best_score=score(plaintext(ciphertext, key))				# set the best score to either the small adjustment value or the new randomized string value depending on what we did above.
	 end
end
