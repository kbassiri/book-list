class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  #
  #
  #Above this line shoul stay **************************************************
  #
  #Generic Product Advertising Ruby API using Nokogiri. Uses Response and Element wrapper classes for easy access to the REST API XML output.

  # It is generic, so you can easily extend Amazon::Ecs to support other not implemented REST operations; and it is also generic because it just wraps around Nokogiri element object, instead of providing one-to-one object/attributes to XML elements map.

  #The idea is as the API evolves, there is a change in REST XML output structure, no updates will be required on amazon-ecs gem, instead you just need to update the element path.

  #For HPricot dependency implementation, please install 1.2.x version or checkout v1.2 branch.
  #
  # Set the default options; options will be camelized and converted to REST request parameters.
  # associate_tag and AWS_access_key_id are required options, associate_tag is required option
  # since API version 2011-08-01. 
  #
  # To sign your request, include AWS_secret_key. 
require 'amazon/ecs'

Amazon::Ecs.options = {
  :associate_tag => '[your associate tag]',
  :AWS_access_key_id => '[your developer token]',       
  :AWS_secret_key => '[your secret access key]'
}

# alternatively,
Amazon::Ecs.configure do |options|
  options[:associate_tag] = '[your associate tag]'
  options[:AWS_access_key_id] = '[your access key]'
  options[:AWS_secret_key] = '[you secret key]'
end

# options provided on method call will merge with the default options
res = Amazon::Ecs.item_search('ruby', {:response_group => 'Medium', :sort => 'salesrank'})

# search amazon uk
res = Amazon::Ecs.item_search('ruby', :country => 'uk')

# search all items, default search index is Books
res = Amazon::Ecs.item_search('ruby', :search_index => 'All')

# some common response object methods
res.is_valid_request?     # return true if request is valid
res.has_error?            # return true if there is an error
res.error                 # return error message if there is any
res.total_pages           # return total pages
res.total_results         # return total results
res.item_page             # return current page no if :item_page option is provided

# traverse through each item (Amazon::Element)
res.items.each do |item|
  # retrieve string value using XML path
  item.get('ASIN')
  item.get('ItemAttributes/Title')

  # return Amazon::Element instance
  item_attributes = item.get_element('ItemAttributes')
  item_attributes.get('Title')

  # return first author or a string array of authors
  item_attributes.get('Author')          # 'Author 1'
  item_attributes.get_array('Author')    # ['Author 1', 'Author 2', ...]

  # return an hash of children text values with the element names as the keys
  item.get_hash('SmallImage') # {:url => ..., :width => ..., :height => ...}

  # return the first matching path as Amazon::Element
  item_height = item.get_element('ItemDimensions/Height')

  # retrieve attributes from Amazon::Element
  item_height.attributes['Units']   # 'hundredths-inches'

  # return an array of Amazon::Element
  authors = item.get_elements('Author')

  # return Nokogiri::XML::NodeSet object or nil if not found
  reviews = item/'EditorialReview'

  # traverse through Nokogiri elements
  reviews.each do |review|
    # Getting hash value out of Nokogiri element
    Amazon::Element.get_hash(review) # [:source => ..., :content ==> ...]

    # Or to get unescaped HTML values
    Amazon::Element.get_unescaped(review, 'Source')
    Amazon::Element.get_unescaped(review, 'Content')

    # Or this way
    el = Amazon::Element.new(review)
    el.get_unescaped('Source')
    el.get_unescaped('Content')
  end
end

# Extend Amazon::Ecs, replace 'other_operation' with the appropriate name
module Amazon
  class Ecs
    def self.other_operation(item_id, opts={})
      opts[:operation] = '[other valid operation supported by Product Advertising API]'

      # setting default option value
      opts[:item_id] = item_id

      self.send_request(opts)
    end
  end
end

Amazon::Ecs.other_operation('[item_id]', :param1 => 'abc', :param2 => 'xyz')
end
