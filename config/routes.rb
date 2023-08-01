# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api_app do
    namespace 'v1' do
      post 'editions/filter', to: 'editions#filter'
    end
  end
end
