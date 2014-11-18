require 'benchmark'

def process_file(filename)
  if filename.end_with? ".compressed"
    run_decompression(filename)
  else
    run_compression(filename)
  end
end

def run_compression(filename)
  # Read the file
  text = File.read(filename)
  new_filename = filename + ".compressed"
  start_time = Time.now
  File.open(new_filename, 'w') do |f|
    index_array = lzw_compress(text)
    f << index_array.pack('l*')
  end
  end_time = Time.now
  # Get and print the output
  time = end_time - start_time
  uncomp_size = File.size(filename)
  comp_size = File.size(new_filename)
  percentage = (comp_size / uncomp_size.to_f).round(2) * 100
  comp_ratio = (uncomp_size / comp_size.to_f).round(2)

  #puts "ORIGINAL ENCODING: #{lzw_compress(text2)}"
  puts "_____________________________________"
  puts "Original file name: \t : #{filename}"
  puts "Compressed file name: \t : #{new_filename}"
  puts "Original file size: \t : #{uncomp_size}"
  puts "Compressed file size: \t : #{comp_size}"
  puts "Compression took #{time} seconds"
  puts "Compressed file is #{100 - percentage}% smaller than the original file"
  puts "Compression Ratio: #{comp_ratio} x"
  puts "_____________________________________"
end


def run_decompression(filename)
  # Read the file
  indices = File.read(filename)
  indices = indices.unpack('l*')
  #puts "ORIGINAL DECODING: #{indices}"
  new_filename = "_" + filename[0..-12]
  #puts lzw_decompress(indices)
  time = Benchmark.measure do |f|
    puts new_filename
    File.open(new_filename, 'w') do |f|
      f << lzw_decompress(indices)
    end
  end
end



def lzw_compress(text)
  # Initialize dictionary, with ASCII_CHAR => ASCII_NUM
  dict = make_dictionary(false)

  # Initialize our output array
  output = []

  # Initialize a counter to track what numbers we've already assigned strings
  counter = dict.length

  # Initialize our string:
  # remove first char of text and assign that char to STR
  str = text[0]
  text[0] = ''
  last_char = text[-1]
  text.each_char do |cur|
    if dict.has_key?(str + cur)
      str << cur
    else
      # Add index of S to output
      output << dict[str]
      # Add s + c to the end of dict
      dict[str << cur] = counter
      # Increase counter
      counter += 1
      # Set S to C
      str = cur
    end
  end

  # Finish things up by adding the remaining chars
  str << last_char
  output << dict[str]

  output
end

def lzw_decompress(indices)
  # Initialize dictionary, with ASCII_NU => ASCII_CHAR
  dict = make_dictionary(true)
  # Initialize our output string
  output = ''
  # Initialize a COUNTER to the next free character in DICT
  counter = dict.length
  # Set CUR to the first array element
  cur = indices.shift
  output += dict[cur]
  # While array is not empty...
  while indices != []
    # Set PREV to CUR
    prev = cur
    # Set CUR to the next array element
    cur = indices.shift
    # If CUR is in the dictionary...
    if dict.has_key?(cur)
      # Set S to CUR's string-value
      str = dict[cur]
      # Add S to the output string
      output << str
      # Add a dict pairing of COUNTER => [PREV's string-val] + [first char of S]
      dict[counter] = dict[prev] + str[0]
      # Increase COUNTER by one
      counter += 1
    # Else...
    else
      # Set S to: [PREV's string-val] + first char of [PREV's string-val]
      prev_val = dict[prev]
      str = prev_val + prev_val[0]
      # Add S to output string
      output << str
      # Add a dict pairing of COUNTER => S
      dict[counter] = str
      # Increase COUNTER
      counter += 1
    end
  end
  # Return output string
  output
end

# INPUT:
# --- Boolean for FALSE if compressing, TRUE if decompressing
# OUTPUT:
# --- Dict of ASCII_CHAR => ASCII_NUMBER if we're compressing
# --- Dict of ASCII_NUMBER => ASCII_CHAR if we're decompressing
def make_dictionary(decompressing)
  dict = {}
  for i in (0..255)
    if decompressing
      dict[i] = i.chr
    else
      dict[i.chr] = i
    end
  end
  dict
end

# puts "Compressing"
# run_compression("test.txt")
# puts "Decompressing"
# run_decompression("test.txt.compressed")

# puts "Compressing"
# run_compression("fundamental_kant.txt")
# puts "Decompressing"
# run_decompression("fundamental_kant.txt.compressed")

puts "Compressing"
run_compression("moby_dick.txt")
puts "Decompressing"
run_decompression("moby_dick.txt.compressed")

# Benchmark.bm(7) do |x|
#   long_string = File.read("moby_dick.txt")
#   x.report("Comparing to empty string:") { (0..100).each { long_string == ''}}
#   x.report ("Finding length:") { (0..100).each {  long_string.length >= 1}}
# end
