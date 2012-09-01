ActiveAdmin.register PhoneCall do
  
  index do
    column :phone_number do |phone_call|
      phone_call.user.phone_number
    end
    column :date do |phone_call|
      phone_call.created_at.in_time_zone("Central Time (US & Canada)")
.strftime("%b %e %l:%M %p ")
    end
    column :recording do |phone_call|
      link_to "recording", phone_call.recording_url if phone_call.recording_url.present?
    end
    column :call_type
    column :status
    column :answered_by

    default_actions
  end
end