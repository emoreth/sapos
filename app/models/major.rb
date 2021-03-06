# Copyright (c) 2013 Universidade Federal Fluminense (UFF).
# This file is part of SAPOS. Please, consult the license terms in the LICENSE file.

class Major < ActiveRecord::Base
  belongs_to :level
  belongs_to :institution
  has_and_belongs_to_many :students, :join_table => "majors_students"

  validates :name, :presence => true
  validates :institution, :presence => true
  validates :level, :presence => true

  def to_label
    "#{name} - #{institution.name} - (#{level.name})"
  end
end