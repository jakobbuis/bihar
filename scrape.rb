require 'mechanize'
require 'json'
require 'digest/sha1'
require './config.rb'

def scrape url, output_filename
    agent = Mechanize.new
    agent.get url do |login_page|
        # Login to the website
        login_page.forms.first.field_with(name: 'SLID').value = $config[:user]
        login_page.forms.first.field_with(name: 'PSWD').value = $config[:password]
        data_page = login_page.forms.first.click_button

        # Check whether the login was succesful, terminating if it's not
        unless data_page.body.include? 'logged in as'
            puts 'Login failed: incorrect username or password'
            exit 1
        end

        # Store the records we build
        records = []

        # Record the current name we're dealing with
        current_name = nil

        # Keep count
        total_entries_captured = 0

        # Parse table
        data_page.search('table').last.search('tr').each do |row|
            # Reject headers rows
            next if row.search('th').length > 0

            # Read all cells
            cells = row.search('td')

            # Update the current name if we enter a new person
            current_name = cells[0].text if cells.length > 6

            # Build data record we need
            if cells.length > 6
                records << {
                    id: Digest::SHA1.hexdigest(current_name),   # Hash name for privacy
                    study_name: cells[2].text,
                    program_code: cells[4].text,
                    start_year: cells[5].text,
                    end_year: cells[6].text[5..8],
                    propedeuse: cells[6].text[0..3] == 'prop',
                    level: cells[3].text,
                }
            else
                records << {
                    id: Digest::SHA1.hexdigest(current_name),   # Hash name for privacy
                    study_name: cells[0].text,
                    program_code: cells[2].text,
                    start_year: cells[3].text,
                    end_year: cells[4].text[5..8],
                    propedeuse: cells[4].text[0..3] == 'prop',
                    level: cells[1].text,
                }
            end

            # Keep tally
            total_entries_captured += 1
        end

        # Write to file
        File.open(output_filename, 'w') do |file|
            file.write JSON.pretty_generate(records)
        end

        # Report success
        puts "Captured #{total_entries_captured} entries into #{output_filename}"
    end
end
