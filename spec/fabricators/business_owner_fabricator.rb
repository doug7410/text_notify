Fabricator(:business_owner) do
  company_name {Faker::Name.first_name + ' ' + Faker::Name.last_name }
  email {Faker::Internet.email}
  password 'password'
end