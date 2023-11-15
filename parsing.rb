require 'nokogiri'
require 'open-uri'
require 'csv'

url = 'https://www.hospitalsafetygrade.org/all-hospitals'
document = Nokogiri::HTML(URI.open(url))

hospital_links = document.css('div.columnWrapper li a')

total = hospital_links.size #общее кол-во больниц для подсчета оставш. времени

CSV.open('hospital_info.csv', 'w') do |csv|

  start_time = Time.now
  hospital_links.each_with_index do |link, index|

    hospital_url = link['href']
    hospital_document = Nokogiri::HTML(URI.open(hospital_url))

    hospital_name = link.text.strip

    hospital_address = hospital_document.css('div.address').text
    hospital_address = hospital_address.gsub("Map and Directions", "")
    hospital_address = hospital_address.gsub(/\s+/, ' ').strip

    if hospital_address.empty?
      csv << [hospital_name, "[ADDRESS] site has blocked access!"]
    else
      csv << [hospital_name, hospital_address]
    end


    if (index % 80 == 0 || index == 9) && index != 0 #оставш. время каждые 80 эл. (+первые 10)
      waiting_time = ((Time.now - start_time) / (index + 1) * (total - index - 1)).to_i
      puts "Processed elements: #{index + 1}/#{total}"
      puts "Estimated waiting time: #{waiting_time/60} min"
      puts "-------------------------------------------------------"
    end

    #вывод в консоль для наглядности
    #puts "#{index} #{hospital_url}"
    #puts hospital_name
    #puts hospital_address

  end

  end_time = Time.now
  puts "Total execution time: #{(end_time - start_time)/60} min"

end
