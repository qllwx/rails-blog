class Article < ApplicationRecord
    include Visible
    has_many :comments,dependent: :destroy

    validates :title, presence: true
    validates :body, presence: true , length: {minimum:10, maxi0mum:30}

end
