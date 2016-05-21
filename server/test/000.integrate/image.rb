#!/usr/bin/env ruby

def main
  img_dir = 'img/'
  files = []
  dummy = 'blank.jpg'

  (9..17).each {|day|
    (0..(23)).each {|hour|
      [0,30].each {|min|
        fname = sprintf(img_dir + '201605%02d_%02d%02d.jpg',
                       day, hour, min)
        files.push(fname)
      }
    }
  }

  files.map! {|f|
    if FileTest.exist? f
      f
    else
      dummy
    end
  }

  system("montage #{files.join(' ')} -tile 48x9 out.jpg")
end

main

