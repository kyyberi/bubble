#!/usr/bin/ruby


require 'nokogiri'
require 'open-uri'
require 'mysql'
require 'date'
require 'net/http'


def getLicenses(*params)
	
	lics = [];
	begin
	
	con = Mysql.new 'localhost', 'thing', 'thing', 'thingiverse'
		querystr = "select distinct license from thing where status='public'"
		rs = con.query(querystr)
		
		
		rs.each_hash do |row|
     			lic = row['license'].to_s
			lics << lic
			
   		end
	rescue Mysql::Error => e
	    	puts e.errno
	    	puts e.error
    
	ensure
    		con.close if con
	end
	
	return lics
end


def getDates(*params)
	
	lics = [];
	begin
	
	con = Mysql.new 'localhost', 'thing', 'thing', 'thingiverse'
		querystr = "select distinct license from thing where status='public'"
		rs = con.query(querystr)
		
		
		rs.each_hash do |row|
     			lic = row['license'].to_s
			lics << lic
			
   		end
	rescue Mysql::Error => e
	    	puts e.errno
	    	puts e.error
    
	ensure
    		con.close if con
	end
	
	return lics
end


def init(*params)
	lics = getLicenses()
	strout = "[\n  ";
	tempr = ""
	debug = true
	tempvalue = 0
	lics.each do |lic|
			strout << "{\n  \"name\": \"" + lic +"\",\n"
			strout << "  \"region\": \"thingiverse\",\n"
			strout << "  \"income\": [\n"
			# hae määrät lisenssille päivittäin
			
			con = Mysql.new 'localhost', 'thing', 'thing', 'thingiverse'
			query = "SELECT license, SUM(remixesscount) as count,  DATE(created) as tdate FROM thing WHERE license='"+ lic +"' GROUP BY YEAR(created), MONTH(created)"
			#puts query
			rs = con.query(query)
			sum = 0
			
			rs.each_hash do |row|
				
	     			count = row['count']
				date = row['tdate'].to_s
				dates = date.split("-")
				if count != ""
					sum = sum.to_f + count.to_f
					sumi = sum.round(0)
					tempr = tempr + "     ["
					tempr = tempr + dates[0]
					tempr = tempr + ","
					#tempr = tempr + "\""
					tempr = tempr + sumi.to_s  
					#tempr = tempr + "\""
					tempr = tempr + "],\n"
					strout <<  tempr
					tempr = ""
					
				end
			end
			strout = strout[0, strout.length - 2]
			strout << "\n"
		   	strout << "   ],\n"
			
			query = "SELECT license, count(thingid) as makes,  DATE(created) as tdate FROM thing WHERE license='"+ lic +"' GROUP BY YEAR(created), MONTH(created)"
			
			#puts query
			rs = con.query(query)
			sum = 0
			strout << "  \"population\": [\n"
			rs.each_hash do |row|
	     			makes = row['makes'].to_s
				date = row['tdate'].to_s
				dates = date.split("-")
				if makes != ""
					sum = sum.to_f + makes.to_f
					sumi = sum.round(0)
					tempr = tempr + "     ["
					tempr = tempr + dates[0]
					tempr = tempr + ","
					#tempr = tempr + "\""
					tempr = tempr + sumi.to_s 
					#tempr = tempr + "\""
					tempr = tempr + "],\n"
					strout <<  tempr
					tempr = ""
				end
			end
			strout = strout[0, strout.length - 2]
			strout << "\n"
		   	strout << "   ],\n"


			query = "SELECT license, SUM(makescount) as makes,  DATE(created) as tdate FROM thing WHERE license='"+ lic +"' GROUP BY YEAR(created), MONTH(created)"
			#puts query
			rs = con.query(query)
			sum = 0
			strout << "  \"lifeExpectancy\": [\n"
			rs.each_hash do |row|
	     			makes = row['makes'].to_s
				date = row['tdate'].to_s
				dates = date.split("-")
				if makes != ""
					sum = sum.to_f + makes.to_f
					sumi = sum.round(0)
					tempr = tempr + "     ["
					tempr = tempr + dates[0]  
					tempr = tempr + ","
					#tempr = tempr + "\""
					tempr = tempr + sumi.to_s
					#tempr = tempr + "\""
					tempr = tempr + "],\n"
					strout <<  tempr
					tempr = ""
				end
			end
			strout = strout[0, strout.length - 2]
			strout << "\n"
		   	strout << "   ]\n},\n"


		
	end
	strout = strout[0, strout.length - 2]
	strout << "\n]"
	puts strout
end

init()
