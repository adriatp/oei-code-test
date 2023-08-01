# frozen_string_literal: true

class School < ApplicationRecord
  has_many :themes
  validates :name, uniqueness: true
end
