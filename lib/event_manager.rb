require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(homenumber)
  clean_number = homenumber.gsub(/[^\d]/, "")
  if clean_number.length == 11 && clean_number[0] == "1"
    clean_number = clean_number[1..10]
  elsif clean_number.nil? || clean_number.length > 10 || clean_number.length < 10
    clean_number = "0000000000"
  else clean_number
  end
end

def legislators_by_zipcode(zip)

  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_day(day)
  format_day = Date.strptime(day, "%m/%d/%y")
  puts Date::DAYNAMES[format_day.wday]
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  homephone = clean_phone_number(row[:homephone])

  time = (row[:regdate]).split[1]

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  puts clean_day(row[:regdate])

end