# frozen_string_literal: true

module ApiApp
  module V1
    class EditionsController < ApplicationController
      def filter
        outcome = Editions::Filter.run(filter_editions_params)
        if outcome.valid?
          @editions = outcome.result
          render json: @editions, status: 200
        else
          render json: { error: I18n.t(outcome.errors.first.type) }, status: 400
        end
      end

      private

      def filter_editions_params
        params.permit(criteria: [], editions: [:date, { courses: %i[name type] }])
      end
    end
  end
end
