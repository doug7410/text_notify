class SmsHandlerService
  def self.find_group(search_string)

    keyword = search_string.scan(/(?<!\S)[A-Z]+(?!\S)/)[0]
    Group.where(name: keyword).first
  end
end 