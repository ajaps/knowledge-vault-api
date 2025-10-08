class Document < ApplicationRecord
  has_many :vaults

  validates :title, presence: true

  scope :search. ->(query) {
    query.present? ? where("title ILIKE :query OR body ILike :query", query: "%#{query}") : all
  }
end
