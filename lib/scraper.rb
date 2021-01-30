require 'open-uri'
require 'pry'

class Scraper

  #Returns an array of hashes, each hash represents a student with their information
  def self.scrape_index_page(index_url)
    doc = Nokogiri::HTML(open(index_url))
    students = doc.css(".student-card")
    students.collect do |student| 
      text_elements = student.css(".card-text-container").children
      hash = {
        :name => text_elements.css("h4.student-name").text, 
        :location => text_elements.css("p.student-location").text, 
        :profile_url => student.css("a").attribute('href').value
      }
    end
  end

  #Returns a hash of profile information for the given student's profile url
  def self.scrape_profile_page(profile_url)
    doc = Nokogiri::HTML(open(profile_url))
    hash = {
      bio: doc.css(".bio-content .description-holder").text.strip,
      profile_quote: doc.css("div.vitals-text-container div.profile-quote").text
    }
    social_info = doc.css("div.social-icon-container a")
    self.add_social_info(social_info, hash)
  end

  #Taking a Nokogiri array of social links, adds the links to the hash
  def self.add_social_info(array,hash={})
    array.each do  |el|
      link = el.attribute('href').value
      if link.match(/^[\w\W]+(twitter)/)
        hash[:twitter] = link 
      elsif link.match(/^[\w\W]+(linkedin)/)
        hash[:linkedin] = link
      elsif link.match(/^[\w\W]+(github)/)
        hash[:github] = link
      elsif link.match(/^(http)/)
        hash[:blog] = link
      else
        nil
      end
    end
    hash
  end
end

