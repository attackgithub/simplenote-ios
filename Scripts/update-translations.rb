#!/usr/bin/env ruby
# encoding: utf-8

# Supported languages:
# ar,cy,zh-Hans,zh-Hant,nl,fr,de,el,he,id,ko,pt,ru,es,sv,tr,ja,it 
# * Arabic
# * Welsh
# * Chinese (China) [zh-Hans]
# * Chinese (Taiwan) [zh-Hant]
# * Dutch
# * French
# * Greek
# * German
# * Hebrew
# * Indonesian
# * Korean
# * Portuguese (Brazil)
# * Russian
# * Spanish
# * Swedish
# * Turkish
# * Japanese
# * Italian
require 'json'

if Dir.pwd =~ /Scripts/
  puts "Must run script from root folder"
  exit
end

ALL_LANGS={
  'ar' => 'ar',         # Arabic
  'cy' => 'cy',         # Welsh
  'de' => 'de',         # German
  'el' => 'el',         # Greek
  'es' => 'es',         # Spanish
  'fr' => 'fr',         # French
  'he' => 'he',         # Hebrew
  'id' => 'id',         # Indonesian
  'it' => 'it',         # Italian
  'ja' => 'ja',         # Japanese
  'ko' => 'ko',         # Korean
  'nl' => 'nl',         # Dutch
  'pt-br' => 'pt-BR',   # Portuguese (Brazil)
  'ru' => 'ru',         # Russian
  'sv' => 'sv',         # Swedish
  'tr' => 'tr',         # Turkish
  'zh-cn' => 'zh-Hans-CN', # Chinese (China)
  'zh-tw' => 'zh-Hant-TW', # Chinese (Taiwan)
}

def copy_header(target_file, trans_strings)
  trans_strings.each_line do |line|
    if (!line.start_with?("/*"))
      target_file.write("\n")
      return
    end 

    target_file.write(line)
  end
end

def copy_comment(f, trans_strings, value)
  prev_line=""
  trans_strings.each_line do |line|
    if line.include?(value)
      f.write(prev_line)
      return 
    end
    prev_line=line
  end
end

langs = {}
if ARGV.count > 0
  for key in ARGV
    unless local = ALL_LANGS[key]
      puts "Unknown language #{key}"
      exit 1
    end
    langs[key] = local
  end
else
  langs = ALL_LANGS
end

langs.each do |code,local|
  lang_dir = File.join('Simplenote', "#{local}.lproj")
  puts "Updating #{code}"
  system "mkdir -p #{lang_dir}"
  
  # Backup the current file
  system "if [ -e #{lang_dir}/Localizable.strings ]; then cp #{lang_dir}/Localizable.strings #{lang_dir}/Localizable.strings.bak; fi"

  # Download translations in JSON format in order to get the string keys
  system "curl -sSfL --globoff -o #{lang_dir}/Localizable.json https://translate.wordpress.com/projects/simplenote%2Fios/#{code}/default/export-translations?format=json" or begin
    puts "Error downloading #{code}"
  end
  trans_json = JSON.parse(File.read("#{lang_dir}/Localizable.json"))

  # Download translations in strings format in order to get the comments
  system "curl -sSfL --globoff -o #{lang_dir}/Localizable.strings.tmp https://translate.wordpress.com/projects/simplenote%2Fios/#{code}/default/export-translations?format=strings" or begin
    puts "Error downloading #{code}"
  end
  trans_strings = File.read("#{lang_dir}/Localizable.strings.tmp")
  
  File.open("#{lang_dir}/Localizable.strings", "w") do |f|
    copy_header(f, trans_strings)
    Hash[trans_json.to_a.reverse].each do | key, value |
      copy_comment(f, trans_strings, value[0]) unless value[0].nil?
      f.write("\"#{key.split("\u0004")[0]}\" = \"#{value[0]}\";\n\n") unless value[0].nil?
    end
  end
  system "./Scripts/fix-translation #{lang_dir}/Localizable.strings"
  system "plutil -lint #{lang_dir}/Localizable.strings" and system "rm #{lang_dir}/Localizable.strings.bak"
  system "rm #{lang_dir}/Localizable.strings.tmp"
  system "rm #{lang_dir}/Localizable.json"
  system "grep -a '\\x00\\x20\\x00\\x22\\x00\\x22\\x00\\x3b$' #{lang_dir}/Localizable.strings"
end
