Fabricator(:group) do
  name {Faker::Lorem.words(6).first}
  user
end