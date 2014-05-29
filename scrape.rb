# Setup
require 'mechanize'
require 'json'
require './config.rb'
agent = Mechanize.new

agent.get 'https://wwwsec.cs.uu.nl/students/cohorts.php?submit=show+me&PROGSEL=all%7Call%7Call&YEAR=&STAT=gestopt&EXAM=pord' do |login_page|
    # Login to the website
    login_page.forms.first.field_with(name: 'SLID').value = $config[:user]
    login_page.forms.first.field_with(name: 'PSWD').value = $config[:password]
    data_page = login_page.forms.first.click_button

    # Check whether the login was succesful (data page has no forms)
    unless data_page.forms.length > 0
        puts 'Login failed'
        exit 1
    end

    # Store the records we build
    records = []

    sub_entry = nil

    # Convert table to JSON-output
    data_page.search('table').last.search('tr').each_with_index do |row, index|
        # Reject headers rows
        next if row.search('th').length > 0

        # Read all cells
        cells = row.search('td')

        # Build data record we need
        unless sub_entry.nil?
            records << {
                name: sub_entry,
                study: cells[0].text,
                level: cells[1].text,
                classic_level: cells[2].text,
                start_year: cells[3].text,
                prop_date: cells[4].text[5..-1]
            }
            sub_entry = nil
        else
            records << {
                name: cells[0].text,
                study: cells[2].text,
                level: cells[3].text,
                classic_level: cells[4].text,
                start_year: cells[5].text,
                prop_date: cells[6].text[5..-1]
            }
        end

        # Minor hack to correctly parse double rows (people with two attempts at studying)
        sub_entry = cells[0].text if cells[0]['rowspan'].to_i > 1
    end

    # Write to file
    File.open('output.json', 'w') do |file|
        file.write JSON.pretty_generate(records)
    end
end
