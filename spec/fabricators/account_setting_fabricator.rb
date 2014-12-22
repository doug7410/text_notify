Fabricator(:account_setting) do
  default_message_subject {Faker::Lorem.words(2).join(" ")}
  default_send_now_message {Faker::Lorem.words(6).join(" ")}
  default_add_to_queue_message {Faker::Lorem.words(6).join(" ")}
  default_send_from_queue_message {Faker::Lorem.words(6).join(" ")}
end