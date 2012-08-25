ActiveAdmin.register User do
  index do
    column :email
    column :first_name
    column :last_name
    column :status
    column :volunteer
    column :admin
    column :on_call
    
    default_actions
  end
  
end