Fabricator(:customer) do
  full_name {Faker::Name.first_name + ' ' + Faker::Name.last_name}
  phone_number '9546381523'
end