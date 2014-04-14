class CreatePostLikes < ActiveRecord::Migration
  def change
    create_table :post_likes do |t|
      t.integer :post_id
      t.integer :user_id
      t.integer :value
    end
  end
end