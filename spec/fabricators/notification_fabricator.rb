Fabricator(:notification) do
  message {Faker::Lorem.words(6).join(" ")}
  user
  sid nil
end