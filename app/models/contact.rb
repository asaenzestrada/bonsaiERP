# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_save :change_nl2br, :unless => lambda { |c| c.address.blank? }

  # relations
  has_many :transactions

  validates_presence_of :name#, :organisation_name
  validates :matchcode, :uniqueness => true, :presence => true
  #, :ctype
  #  validates_inclusion_of :ctype, :in => TYPES

  attr_accessible :name, :matchcode, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info
  
  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

  def to_s
    name
  end

private

  # Format addres to present on the
  def change_nl2br
    self.address.gsub!("\n", "<br/>")
  end

end
