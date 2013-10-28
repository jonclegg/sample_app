#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'date'
require 'csv'
require 'open-uri'
require 'json'

statemap = {}
CSV.foreach("States.csv") do |row|
  statemap[row[0]] = row[1]
end

stateabbr2id = {}

districtzips = {}
filecount = 0
file = File.new("districtzipfiles.txt", "r")
while (line = file.gets)
   webfile = open(line) {|f| f.read }
   lineno = 0
   filecount += 1
   stateid = 0
   curstate = {}
   statename = ""
   webfile.lines do |line|
      row = CSV.parse(line)[0]
      lineno += 1
      if lineno == 1
         statename = /(.+)\bCONGRESSIONAL/.match(row[0])[1].strip!
      end
      if lineno <= 2
         next
      end
      sid = row[0].to_i
      zip = row[1].to_i
      if districtzips[sid] == nil
         districtzips[sid] = {}
      end
      if districtzips[sid][zip] == nil
         districtzips[sid][zip] = []
      end
      districtzips[sid][zip].push(row[2].to_i)
      if lineno == 3
         stateabbr = statemap[statename]
         stateabbr2id[stateabbr] = sid;
#         printf "\"%s\" => %s,\n", stateabbr, row[0]
      end
   end
   #pp(curstate)
   if filecount > 2
     break
   end
end

#puts JSON.pretty_generate(stateabbr2id)

#pp(districtzips)
#puts JSON.pretty_generate(districtzips)
#puts districtzips.to_json


legislators = YAML.load_file('legislators-current.yaml')

senators = []
congress = []
all = {}
legislators.each do |leg|
   leg["terms"].each do |term|
      enddate = Date.parse(term["end"])
      if enddate > DateTime.now
        if term["type"] == "sen"
          senators.push({
             :first => leg["name"]["first"], 
             :last => leg["name"]["last"], 
             :party => term["party"],
             :enddate => enddate,
             :type => term["type"],
             :state => term["state"]  
          })
        else
          congress.push({
             :first => leg["name"]["first"], 
             :last => leg["name"]["last"], 
             :party => term["party"],
             :enddate => enddate,
             :type => term["type"],
             :state => term["state"], 
             :district => term["district"]  
          })
        end
      end
   end
   #pp(l["terms"])
   #break
end

all["sen"] = senators
all["con"] = congress
puts JSON.pretty_generate(all)
#sorted = senators.sort_by {|k| k[:enddate]}
#pp(sorted)
#puts sorted.length


