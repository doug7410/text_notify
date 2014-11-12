Fabricator(:notification) do
  message {Faker::Lorem.words(6).join(" ")}
  sid nil
end