# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

school_education = School.where(name: 'educacion').first_or_create(name: 'educacion')
school_education.themes.create(name: 'infantil')
school_education.themes.create(name: 'competencias-digitales')
school_education.themes.create(name: 'gobernanza')

school_lenguas = School.where(name: 'lenguas').first_or_create(name: 'lenguas')
school_lenguas.themes.create(name: 'portugues')

school_ciencia_cultura = School.where(name: 'ciencia-y-cultura').first_or_create(name: 'ciencia-y-cultura')
school_ciencia_cultura.themes.create(name: 'educacion-artistica')
school_ciencia_cultura.themes.create(name: 'divulgacion-cientifica')

school_cooperacion = School.where(name: 'cooperacion').first_or_create(name: 'cooperacion')
school_cooperacion.themes.create(name: 'cooperacion')
