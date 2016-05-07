#!/usr/bin/env ruby
# -*- coding: euc-jp -*-

require 'open3'

ROOT_DIR = File.expand_path(File.dirname(__FILE__) + '/../../')
LOG_DIR = ROOT_DIR + '/log'
TIME = Time.new.strftime('%H%M')
DATE = Time.new.strftime('%Y%m%d')

def readData(date, time)
  humidity = 0
  celsius = 0
  illuminance = 0
  moisture = 0
  imgFile = "#{date}_#{time}.jpg"
  imgFilePath = LOG_DIR + "/img/#{imgFile}"

  Open3.popen3(ROOT_DIR + '/c/humidity-sensor/humidity -1') {|stdin, stdout, stderr|
    /humidity:([\d\.]+) celsius:([\d\.]+)/ =~ stdout.read
    humidity = $1
    celsius =  $2
  }

  Open3.popen3(ROOT_DIR + '/c/mcp3204/mcp3204') {|stdin, stdout, stderr|
    /illuminance: ([\d\.]+) lux\nmoisture: ([\d\.]+) %/ =~ stdout.read
    illuminance = $1
    moisture =  $2
  }

  return {
    humidity: humidity,
    celsius: celsius,
    illuminance: illuminance,
    moisture: moisture,
  };
end

def writeData(date, time, v)
  file = LOG_DIR + "/#{date}_01min.csv"

  if FileTest.exist?(file) == false
    File.open(file, 'a') do |file|
      file.puts 'date,humidity,celsius,illumination,moisture'
    end
  end

  p v

  File.open(file, 'a') do |file|
    file.puts "#{date}_#{time},#{v[:humidity]},#{v[:celsius]},#{v[:illuminance]},#{v[:moisture]}"
  end
end

def recordData(date, time)
  value = readData(date, time)
  writeData(date, time, value)
end

def main
  recordData(DATE, TIME)
end

main
