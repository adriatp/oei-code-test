# frozen_string_literal: true

module Editions
  class Filter < ApplicationInteractor
    array :criteria
    array :editions

    def execute
      return false unless valid_payload?

      filter_by_criteria(editions, criteria) if criteria.present? && editions.present?
    end

    def filter_by_criteria(editions, criteria)
      date_courses = []
      editions.each do |e|
        list_idx_courses = (0..e[:courses].count - 1).to_a
        criteria.filter { |x| x.include? 'type' }.each do |tc|
          list_idx_courses = list_idx_courses.intersection(idx_courses_by_type(e[:courses], tc.split('-', 2)[1]))
        end
        criteria.filter { |x| x.include? 'school' }.each do |sc|
          list_idx_courses = list_idx_courses.intersection(idx_courses_by_school(e[:courses], sc.split('-', 2)[1]))
        end
        name_filtered_courses = e[:courses].values_at(*list_idx_courses).pluck(:name)
        next unless name_filtered_courses.present?

        date_courses << {
          date: e[:date],
          courses: name_filtered_courses
        }
      end
      if date_courses.count > 1 && criteria.include?('closest')
        date_courses = closest_date_courses(date_courses)
      elsif date_courses.count > 1 && criteria.include?('latest')
        date_courses = latest_date_courses(date_courses)
      end
      date_courses
    end

    def closest_date_courses(date_courses)
      sf_date_courses = sorted_following_date_courses(date_courses)
      sf_date_courses.select do |dc|
        dc[:date] == sf_date_courses.first[:date]
      end
    end

    def latest_date_courses(date_courses)
      sf_date_courses = sorted_following_date_courses(date_courses)
      sf_date_courses.select do |dc|
        dc[:date] == sf_date_courses.last[:date]
      end
    end

    def sorted_following_date_courses(date_courses)
      date_now = DateTime.now.to_date
      date_courses = date_courses.sort_by { |dc| dc[:date] }
      date_courses.filter { |dc| dc if Date.parse(dc[:date]) >= date_now }
    end

    def sorted_following_edition_dates(editions)
      date_now = DateTime.now.to_date
      edition_dates = editions.pluck(:date).map { |x| Date.parse(x) }
      following_edition_dates = edition_dates.filter { |x| x if x >= date_now }
      following_edition_dates.sort
    end

    def idx_courses_by_type(courses, type_name)
      courses.each_index.select { |i| courses[i][:type] == type_name }
    end

    def idx_courses_by_school(courses, school_name)
      valid_types = School.find_by(name: school_name).themes&.pluck(:name).to_a
      courses.each_index.select { |i| valid_types.include? courses[i][:type] }
    end

    # Validations

    def valid_payload?
      if conflicting_criteria? criteria
        errors.add(:base, 'criteria.conflict')
        return false
      end
      criteria.each do |c|
        unless valid_criteria? c
          errors.add(:base, 'criteria.invalid')
          return false
        end
      end
      editions.each do |e|
        unless valid_date? e[:date]
          errors.add(:base, 'date.invalid')
          return false
        end
        e[:courses].each do |c|
          unless valid_type? c[:type]
            errors.add(:base, 'type.invalid')
            return false
          end
        end
        return true
      end
    end

    def conflicting_criteria?(criteria)
      (criteria.include? 'closest') && (criteria.include? 'latest')
    end

    def valid_criteria?(criteria)
      return true if %w[closest latest].include?(criteria)

      criteria_splitted = criteria.split('-', 2)
      return false if criteria_splitted.count != 2

      if criteria_splitted[0] == 'type'
        return true if Theme.find_by(name: criteria_splitted[1]).present?
      elsif criteria_splitted[0] == 'school'
        return true if School.find_by(name: criteria_splitted[1]).present?
      end
      false
    end

    def valid_date?(date)
      date_splitted = date.split('-')
      return false if date_splitted.count != 3

      Date.new(Integer(date_splitted[0], 10), Integer(date_splitted[1], 10), Integer(date_splitted[2], 10))
      true
    rescue StandardError
      false
    end

    def valid_type?(type)
      Theme.find_by(name: type).present?
    end
  end
end
