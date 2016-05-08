#!/usr/bin/ruby --
# -*- coding: utf-8 -*-

require 'cgi'

ROOT_DIR = File.expand_path(File.dirname(__FILE__) + '/../')
LOG_DIR = ROOT_DIR + '/log'

print "Content-type: text/html\n\n"

cgi = CGI.new

value = cgi.params['01min'][0]
outFile = LOG_DIR + '/' + value.original_filename
puts "file name : " <<  value.original_filename  << "<br/>" # ファイル名
p outFile
File.open(outFile, "w") { |file|
  file.print value.read
}

value = cgi.params['30min'][0]
outFile = LOG_DIR + '/' +  value.original_filename
puts "file name : " <<  value.original_filename  << "<br/>" # ファイル名
File.open(outFile, "w") { |file|
  file.print value.read
}

value = cgi.params['img'][0]
outFile = LOG_DIR + '/img/' + value.original_filename
puts "file name : " <<  value.original_filename  << "<br/>" # ファイル名
File.open(outFile, "w") { |file|
  file.print value.read
}

