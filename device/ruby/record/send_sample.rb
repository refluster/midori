#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "net/http"
require "uri"

#ROOT_DIR = File.expand_path(File.dirname(__FILE__) + '/../../')
#LOG_DIR = ROOT_DIR + '/log'

class FileUploader
  def initialize
    @uri = URI.parse "http://192.168.2.1:8880/upload.cgi"
#    @uri = URI.parse "http://lab.schememono.net/midori/server/api/upload.cgi"
    @request = Net::HTTP::Post.new @uri.path
  end

  def uploadFile(fileInfos)
    Net::HTTP.start(@uri.host, @uri.port) {|http|
      # header
      @request["user-agent"] = "Ruby/#{RUBY_VERSION} rubyHttpClient"
      @request["content-type"] = "multipart/form-data; boundary=myboundary"
      
      # body
      body = "--myboundary\r\n"
      body += "content-disposition: form-data; name=\"id\";\r\n"
      body += "\r\n"
      body += "1\r\n"
      
      fileInfos.each {|fi|
        fname = File.basename fi[:path]
        body += "--myboundary\r\n"
        body += "content-disposition: form-data; name=\"#{fi[:name]}\"; filename=\"#{fname}\"\r\n"
        body += "\r\n"
        File::open(fi[:path]) {|f|
          body += f.read + "\r\n"
        }
      }

      body += "--myboundary--\r\n"
      @request.body = body
      
      # send
      response = http.request @request
      
      p response
      p response.body
    }
  end
end

def main
  uploader = FileUploader.new
  uploader.uploadFile([
                       {name: '01min',
                         path: "/Users/uehara/mnt/work/midori/device/log/20160508_01min.csv"},
                       {name: '30min',
                         path: "/Users/uehara/mnt/work/midori/device/log/20160508_30min.csv"},
                       {name: 'img',
                         path: "/Users/uehara/mnt/work/midori/device/log/img/20160508_1300.jpg"},
                      ])
end

#main
