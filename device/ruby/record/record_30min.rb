#!/usr/bin/env ruby
# -*- coding: euc-jp -*-

require 'open3'
require_relative 'send_sample'

ROOT_DIR = File.expand_path(File.dirname(__FILE__) + '/../../')
LOG_DIR = ROOT_DIR + '/log'
TIME = Time.new.strftime('%H%M')
DATE = Time.new.strftime('%Y%m%d')
DATE_MINUS_1MIN = (Time.new - 60).strftime('%Y%m%d')

def readData(date, time)
  humidity = 0
  celsius = 0
  illuminance = 0
  moisture = 0
  imgFile = "#{date}_#{time}.jpg"
  imgFilePath = LOG_DIR + "/img/#{imgFile}"

  Open3.popen3(ROOT_DIR + '/c/humidity-sensor/humidity -1') {|stdin, stdout, stderr|
    /humidity:([\d\.]+)/ =~ stdout.read
    humidity = $1
  }

  Open3.popen3(ROOT_DIR + '/c/mcp3204/mcp3204') {|stdin, stdout, stderr|
    /illuminance: ([\d\.]+) .*\nmoisture: ([\d\.]+) .*\ncelsius: ([\d\.]+)/ =~ stdout.read
    illuminance = $1
    moisture =  $2
    celsius =  $3
  }

  cmdCamera = ROOT_DIR + "/c/camera/camera -b 20 -c 60 -g 100 -s 80 -r 160x120 -o #{imgFilePath}"
  Open3.capture3(cmdCamera)

  return {
    humidity: humidity,
    celsius: celsius,
    illuminance: illuminance,
    moisture: moisture,
    camera: imgFile
  };
end

def writeData(date, time, v)
  file = LOG_DIR + "/#{date}_30min.csv"

  if FileTest.exist?(file) == false
    File.open(file, 'a') do |file|
      file.puts 'date,humidity,celsius,illumination,moisture,camera'
    end
  end

  p v

  File.open(file, 'a') do |file|
    file.puts "#{date}_#{time},#{v[:humidity]},#{v[:celsius]},#{v[:illuminance]},#{v[:moisture]},#{v[:camera]}"
  end
end

def upload(date, time, date_minus_1min)
  imgFile = "#{date}_#{time}.jpg"
  f30min = LOG_DIR + "/#{date}_30min.csv"
  f01min = LOG_DIR + "/#{date_minus_1min}_01min.csv"
  fImg = LOG_DIR + "/img/#{imgFile}"

  uploader = FileUploader.new
  uploader.uploadFile([
                       {name: '01min',
                         path: f01min},
                       {name: '30min',
                         path: f30min},
                       {name: 'img',
                         path: fImg},
                      ])
end

def recordData(date, time, date_minus_1min)
  value = readData(date, time)
  writeData(date, time, value)
  upload(date, time, date_minus_1min)
end

def main
  recordData(DATE, TIME, DATE_MINUS_1MIN)
end

main

