# Bihar

Small scraper tool using mechanize for a Business Intelligence project. Collects to a specific page on the [cs.uu.nl](http://www.cs.uu.nl/) website and collects some data about people who've left (not completed) any programme. 

## Installation
Requires ruby and bundler. Copy config.example.rb to config.rb and enter your UU (solis) credentials. 

## Usage
Run `ruby scrape.rb`. Prettified JSON appears in output.json. On my recent ultrabook, the script takes about 2.5 seconds to run. 

## License 
Copyright Jakob Buis 2014. All rights reserved.
