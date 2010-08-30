class CreateHighrises < ActiveRecord::Migration
  def self.up
    create_table :highrise_settings do |t|
      t.string  :authentication_token
      t.string  :subdomain
      t.integer :task_category
      t.integer :task_owner
      t.timestamps
    end
  end

  def self.down
    drop_table :highrise_settings
  end
end
