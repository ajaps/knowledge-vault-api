# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :vault
  
  validates :title, presence: true
  validates :vault_id, presence: true
  validates :file_path, presence: true
  
  before_destroy :remove_file
  
  scope :search_by_title, ->(query) { 
    where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? 
  }
  
  scope :search_by_content, ->(query) {
    where("title ILIKE :query OR metadata::text ILIKE :query", 
          query: "%#{sanitize_sql_like(query)}%") if query.present?
  }
  
  scope :by_category, ->(category) { 
    where("metadata->>'category' = ?", category) if category.present? 
  }
  
  scope :by_tag, ->(tag) { 
    where("metadata->'tags' ? :tag", tag: tag) if tag.present? 
  }
  
  scope :by_content_type, ->(content_type) {
    where("content_type LIKE ?", "%#{sanitize_sql_like(content_type)}%") if content_type.present?
  }

  
  scope :sort_by_param, ->(sort_param) {
    case sort_param
    when 'title_asc'
      order(title: :asc)
    when 'title_desc'
      order(title: :desc)
    else
      order(created_at: :desc)
    end
  }
  
  def self.full_text_search(query)
    return all if query.blank?
    
    search_by_content(query)
  end
  
  def owner?(user)
    vault.user_id == user.id
  end
  
  def file_url
    return nil unless file_path
    "/api/v1/vaults/#{vault_id}/documents/#{id}/download"
  end
  
  private
  
  def remove_file
    File.delete(file_path) if file_path && File.exist?(file_path)
  rescue StandardError => e
    Rails.logger.error("Failed to delete file #{file_path}: #{e.message}")
  end
end