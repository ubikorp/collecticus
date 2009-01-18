# == Schema Information
# Schema version: 20
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  bio                       :text          
#  interests                 :text          
#  location                  :string(255)   
#

require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_authorized_user
  acts_as_authorizable
  
  has_many :comments,
           :dependent => :destroy,
           :order => "created_at DESC",
           :extend => PaginationExtension do
             def recent(limit = 5)
               find(:all, :order => "created_at DESC", :limit => limit)
             end
           end
  
  has_and_belongs_to_many :books do # collection
    def by_publisher(publisher)
      find(:all, :conditions => ["publisher_id = ?", publisher.id])
    end

    def by_week(date)
      week = date.beginning_of_week
      find(:all, :conditions => ["published_on > ? AND published_on < ?",
        week, week + 7.days]).sort_by { |book| book.name }
    end

    def released_this_week
      by_week(Time.now)
    end    
  end
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  def to_param
    login
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  # Return the average rating assigned to books by this user
  def average_rating
    Rating.average(:rating, :conditions => "user_id = #{id}")
  end
  
  # Return the <limit> most recent book ratings created by this user
  def recent_ratings(limit = 5)
    Rating.find(:all, :conditions => "user_id = #{id}",
                :order => "created_at DESC", :limit => limit)
  end
  
  # Return the <limit> most recent comments left by this user
  def recent_comments(limit = 5)
    self.comments.recent(limit)
  end
  
  # Return series in which this user owns at least one book
  def series
    Series.find_by_sql("SELECT series.* FROM series
                          LEFT JOIN books ON series.id = books.series_id
                          LEFT JOIN books_users ON books.id = books_users.book_id
                          WHERE books_users.user_id = #{id}
                          GROUP BY series.id")
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
