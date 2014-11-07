Fabricator(:customer) do
  first_name {Faker::Name.first_name}
  last_name {Faker::Name.last_name}
  phone_number '555-555-5555'
end