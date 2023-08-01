# frozen_string_literal: true

class Theme < ApplicationRecord
  belongs_to :school
  validates :name, uniqueness: { scope: :school }
end
