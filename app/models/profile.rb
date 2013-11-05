#
# microphisher - a spear phishing support tool
#
# Created by Ulisses Albuquerque & Joaquim Espinhara
# Copyright (C) 2013 Trustwave Holdings, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class Profile
  include Mongoid::Document

  # Attribute listing
  field :name, type: String
  field :description, type: String
  field :collection_yaml, type: String
  field :selector, type: String
  field :status, type: String, default: 'pending'
  
  # Validations
  validates :name, :selector, presence: true
  validates :name, uniqueness: true

  # Relations
  belongs_to :unknown_subject
  
  def treat_collection
    return nil if self.collection_yaml.nil?
    return @treat_collection unless @treat_collection.nil?
    @treat_collection = YAML.load(self.collection_yaml)
  end
  
  def treat_collection=(collection_object = nil)
    Dir.mktmpdir do |directory|
      yaml_filename = File.join(directory, 'collection_yaml')
      collection_object.serialize :yaml, :file => yaml_filename
      self.collection_yaml = File.read(yaml_filename)
    end
    @treat_collection = collection_object
  end
  
  def status_updates
    StatusUpdate.where(eval self.selector)
  end
  
  # All users mentioned in status updates associated with this profile,
  # ranked by frequency in a hashtable
  def user_mentions
    return {} if self.collection_yaml.nil?
    return self[:user_mentions] unless self[:user_mentions].nil?

    # Obtain all user mention entities from all eligible status updates
    mentions = status_updates.map do |status_update|
      status_update['entities']['user_mentions']
    end
    
    # Count all user references in all entity entries
    self[:user_mentions] = Hash.new { 0 }
    mentions.each do |mention|
      mention.each do |user|
        self[:user_mentions]["@#{user['screen_name']}"] += 1
      end
    end
    self.save!

    self[:user_mentions]
  end
  
  # All hashtags mentioned in status updates associated with this profile,
  # ranked by frequency in a hashtable
  def hashtag_mentions
    return {} if self.collection_yaml.nil?
    return self[:hashtag_mentions] unless self[:hashtag_mentions].nil?

    # Obtain all hashtag mention entities from all eligible status updates
    mentions = status_updates.map do |status_update|
      status_update['entities']['hashtags']
    end
    
    # Count all hashtag references in all entity entries
    self[:hashtag_mentions] = Hash.new { 0 }
    mention_counter = mentions.each do |mention|
      mention.each do |hashtag|
        self[:hashtag_mentions]["\##{hashtag['text']}"] += 1
      end
    end
    self.save!

    self[:hashtag_mentions]
  end

  # Average number of words per status update associated with this profile
  def average_word_count
    return 0 if self.collection_yaml.nil?
    return self[:average_word_count] unless self[:average_word_count].nil?
    
    self[:average_word_count] = (self.treat_collection.documents.inject(0) do |t, doc|
      t + doc.words.size
    end) / self.treat_collection.documents.size
    self.save!
    
    self[:average_word_count]
  end
    
  # All words present in all documents, ranked by their tf_idf scores in a hash
  def dictionary
    return {} if self.collection_yaml.nil?
    return self[:dictionary] unless self[:dictionary].nil?
    
    document_words = self.treat_collection.documents.map { |doc| doc.words }
    
    self[:dictionary] = Hash.new
    document_words.each do |word_list|
      word_list.each do |word|
        dictionary[word.to_s.downcase] = word.tf_idf
      end
    end
    self.save!
    
    self[:dictionary]
  end
  
  # Return the list of stop words associated with the language identified by Treat
  # as the primary language used in the status update collection
  def stop_words
    return {} if self.collection_yaml.nil?
    return self[:stop_words] unless self[:stop_words].nil?
    
    self[:stop_words] = Treat.languages[self.treat_collection.language].stop_words
    self.save!
    
    self[:stop_words]
  end
      
  def build_profile!
    # Update current status
    self.set(:status, 'indexing')
    
    Dir.mktmpdir do |directory|
      # Create a treat collection for the documents associated with each tweet
      collection_path = File.join(directory, 'profile')
      status_update_collection = Treat::Entities::Collection.new(collection_path)
      
      # Iterate over all tweets
      self.status_updates.each do |status_update|
        status_update_collection << Treat::Entities::Document.new(status_update.text)
      end
      
      # Fully parse and extract entities from the documents contained in the collection
      logger.info("Processing #{status_update_collection.documents.size} status updates")
      # self.treat_collection = status_update_collection.apply(:chunk, :segment, :tokenize,
      #  :category, :keywords)
      self.treat_collection = status_update_collection.apply(:chunk, :segment, :tokenize,
        :category, :name_tag, :keywords, :tag => :stanford)
        
      self.save!
    end

    # Update current status
    self.set(:status, 'complete')
  end
end
