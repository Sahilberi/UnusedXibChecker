#!/usr/bin/ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class UnusedXibChecker
  def find
    # Collect all .xib files
    all_xibs = Dir.glob("**/*.xib").reject { |path| File.directory?(path) }

    # Extract .xib names without extensions
    xib_names = all_xibs.map { |xib| File.basename(xib, ".xib") }
    puts "Found XIBs: #{xib_names.length}"
    puts xib_names.join("\n")

    # Read other files to find references to these .xib names
    other_files = Dir.glob("**/*.{swift,m,h}").reject { |path| File.directory?(path) }
    puts "\nSearching in other files for XIB references..."

    find_references_in_files(xib_names, other_files)
  end

  def find_references_in_files(xib_names, files)
    xib_references = xib_names.map { |name| [name, 0] }.to_h

    files.each do |file|
      lines = File.readlines(file).map { |line| line.gsub(/^\s*\/\/.*/, "") }
      content = lines.join("\n")

      xib_names.each do |name|
        xib_references[name] += content.scan(/\b#{Regexp.escape(name)}\b/).count
      end
    end

    single_reference_xibs = xib_references.select { |_, count| count == 1 }
    if single_reference_xibs.any?
      puts "\nXIBs with a single reference:"
      single_reference_xibs.each { |name, _| puts name }
    else
      puts "\nNo XIBs with a single reference found."
    end
  end
end

UnusedXibChecker.new.find
