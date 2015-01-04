shared_examples 'add to txt queue' do
  it '[creates a new queue item]', :vcr do
    action
    expect(QueueItem.count).to eq(1)
  end

  it '[associated the new notification with the queue item]', :vcr do
    action
    expect(QueueItem.first.notification).to eq(Notification.first)
  end

  it '[associated the business_owner with the queue item]', :vcr do
    action
    expect(QueueItem.first.business_owner).to eq(bob_business_owner)
  end

  it '[sets the @queue_items]', :vcr do
    action
    expect(assigns(:queue_items).count).to eq(1)
  end

  it '[sends with default message if the message is left blank]', :vcr do
    xhr :post, :create,
        notification: {
          message: '',
          business_owner_id: bob_business_owner.id
        },
        customer: { phone_number: phone_number },
        commit: 'send later'
    message = bob_business_owner.default_add_to_queue_message
    expect(Notification.first.message).to eq(message)
  end
end
