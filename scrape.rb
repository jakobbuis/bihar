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

# <tr>
# 0<td><a href="/students/cohorts.php?STAT=gestopt&amp;EXAM=pord&amp;PROG=info">informatica</a></td>
# 1<td><a href="/students/cohorts.php?STAT=gestopt&amp;EXAM=pord&amp;TYPE=doct">doctoral</a></td>
# 2<td><a href="/students/cohorts.php?STAT=gestopt&amp;EXAM=pord&amp;OPLD=CS-classic">CS-classic</a></td>
# 3<td><a href="/students/cohorts.php?STAT=gestopt&amp;EXAM=pord&amp;YEAR=2000">2000</a></td>
# 4<td><font color="FUCHSIA"><b>prop</b> 2001-07-09</font></td>
# </tr>



# <TR>
# 0<TD ROWSPAN=1><A HREF="/students/stud/0018953.html">Aarts, H.</A></TD>
# 1<TD ROWSPAN=1>Harm</TD>
# 2<TD><A HREF="/students/cohorts.php?STAT=gestopt&EXAM=pord&PROG=info">informatica</A></TD>
# 3<TD><A HREF="/students/cohorts.php?STAT=gestopt&EXAM=pord&TYPE=doct">doctoral</A></TD>
# 4<TD><A HREF="/students/cohorts.php?STAT=gestopt&EXAM=pord&OPLD=CS-classic">CS-classic</A></TD>
# 5<TD><A HREF="/students/cohorts.php?STAT=gestopt&EXAM=pord&YEAR=2000">2000</A></TD>
# 6<TD><FONT COLOR="FUCHSIA"><B>prop</B> 2001-08-24</FONT></TD>
# </TR>

# Naam= "Aarts, H."
# Study= "informatica"
# Level = "doctoral"
# Classic_level = "CS-classic"
# Start_year = "2000"
# Prop_date = "2001-08-24" (dus min prop ervoor, als dat lukt)
# vorige klopte niet
# roepnaam is beetje onzinnig om te scrapen dus die als enige eruit
