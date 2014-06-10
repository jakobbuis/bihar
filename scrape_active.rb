# Setup
require './scrape.rb'

scrape 'https://wwwsec.cs.uu.nl/students/cohorts.php?PROGSEL=all|all|all&STAT=actief', 'output_active.json'
