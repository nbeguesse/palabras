class Infinitive < ActiveRecord::Base
  has_many :verbs, :dependent=>:destroy
  validates_presence_of :name
  validates_presence_of :meaning
  validates_uniqueness_of :name
  before_save :lowercase_name

  def lowercase_name
    self.name = name.downcase
  end


end
