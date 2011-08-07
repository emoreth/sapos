class Enrollment < ActiveRecord::Base
  belongs_to :student
  belongs_to :level
  belongs_to :enrollment_status
  has_one :dismissal, :dependent => :destroy
  has_many :advisements, :dependent => :destroy
  has_many :professors, :through => :advisements
  has_many :scholarship_durations, :dependent => :destroy
  has_many :scholarships, :through => :scholarship_durations
    
  def to_label
    "#{enrollment_number}"
  end
  
  validates_uniqueness_of :enrollment_number
end
