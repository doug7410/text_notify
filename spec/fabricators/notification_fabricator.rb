Fabricator(:notification) do
  message {Faker::Lorem.words(6).join(" ")}
  business_owner
  sid = 'SM679e554b253b4bbc8b5e2f4178037a5f'
end