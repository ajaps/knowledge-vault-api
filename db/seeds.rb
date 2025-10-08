puts "Cleaning database..."
Document.destroy_all
Vault.destroy_all
User.destroy_all

puts "Creating sample users..."

# Create sample users
alice = User.create!(
  name: "Alice Johnson",
  email: "alice@example.com"
)

bob = User.create!(
  name: "Bob Smith",
  email: "bob@example.com"
)

charlie = User.create!(
  name: "Charlie Davis",
  email: "charlie@example.com"
)

puts "✓ Created #{User.count} users"
puts "  Alice's API Key: #{alice.api_key}"
puts "  Bob's API Key: #{bob.api_key}"
puts "  Charlie's API Key: #{charlie.api_key}"

puts "\nCreating vaults..."

# Alice's vaults
alice_tech_vault = alice.vaults.create!(
  name: "Technical Documentation",
  description: "All technical specs and API documentation"
)

alice_design_vault = alice.vaults.create!(
  name: "Design Resources",
  description: "UI/UX designs and brand guidelines"
)

# Bob's vaults
bob_project_vault = bob.vaults.create!(
  name: "Project Alpha",
  description: "Confidential project documentation"
)

bob_research_vault = bob.vaults.create!(
  name: "Research Papers",
  description: "Academic and industry research"
)

# Charlie's vaults
charlie_vault = charlie.vaults.create!(
  name: "Team Knowledge Base",
  description: "Shared team resources and guides"
)

puts "✓ Created #{Vault.count} vaults"

puts "\nCreating sample documents..."

# Create storage directories
FileUtils.mkdir_p(Rails.root.join('storage', 'documents'))

# Helper to create sample file
def create_sample_file(user_id, vault_id, filename, content)
  dir = Rails.root.join('storage', 'documents', user_id.to_s, vault_id.to_s)
  FileUtils.mkdir_p(dir)
  
  filepath = dir.join(filename)
  File.write(filepath, content)
  filepath.to_s
end

# Alice's technical documents
alice_tech_vault.documents.create!(
  title: "API Reference Guide",
  file_path: create_sample_file(
    alice.id, 
    alice_tech_vault.id, 
    "api_reference.md",
    "# API Reference\n\nComplete API documentation..."
  ),
  content_type: "text/markdown",
  file_size: 1024,
  metadata: {
    category: "technical",
    tags: ["api", "reference", "documentation"],
    version: "1.0",
    author: "Alice Johnson"
  }
)

alice_tech_vault.documents.create!(
  title: "Database Schema",
  file_path: create_sample_file(
    alice.id,
    alice_tech_vault.id,
    "database_schema.sql",
    "-- Database Schema\nCREATE TABLE users..."
  ),
  content_type: "application/sql",
  file_size: 2048,
  metadata: {
    category: "technical",
    tags: ["database", "schema"],
    version: "2.1"
  }
)

alice_tech_vault.documents.create!(
  title: "Authentication Flow",
  file_path: create_sample_file(
    alice.id,
    alice_tech_vault.id,
    "auth_flow.pdf",
    "Mock PDF content for authentication flow diagram"
  ),
  content_type: "application/pdf",
  file_size: 3072,
  metadata: {
    category: "technical",
    tags: ["security", "authentication"],
    confidential: true
  }
)

# Alice's design documents
alice_design_vault.documents.create!(
  title: "Brand Guidelines 2024",
  file_path: create_sample_file(
    alice.id,
    alice_design_vault.id,
    "brand_guidelines.pdf",
    "Mock PDF content for brand guidelines"
  ),
  content_type: "application/pdf",
  file_size: 5120,
  metadata: {
    category: "design",
    tags: ["branding", "guidelines"],
    year: 2024
  }
)

alice_design_vault.documents.create!(
  title: "UI Component Library",
  file_path: create_sample_file(
    alice.id,
    alice_design_vault.id,
    "ui_components.sketch",
    "Mock Sketch file content"
  ),
  content_type: "application/sketch",
  file_size: 8192,
  metadata: {
    category: "design",
    tags: ["ui", "components", "library"],
    tool: "Sketch"
  }
)

# Bob's project documents
bob_project_vault.documents.create!(
  title: "Project Roadmap Q1 2024",
  file_path: create_sample_file(
    bob.id,
    bob_project_vault.id,
    "roadmap_q1.xlsx",
    "Mock Excel content"
  ),
  content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  file_size: 4096,
  metadata: {
    category: "planning",
    tags: ["roadmap", "q1", "2024"],
    confidential: true
  }
)

bob_project_vault.documents.create!(
  title: "Technical Architecture",
  file_path: create_sample_file(
    bob.id,
    bob_project_vault.id,
    "architecture.md",
    "# System Architecture\n\n## Overview\nThis document describes..."
  ),
  content_type: "text/markdown",
  file_size: 2560,
  metadata: {
    category: "technical",
    tags: ["architecture", "system-design"]
  }
)

# Bob's research documents
bob_research_vault.documents.create!(
  title: "Machine Learning Survey 2024",
  file_path: create_sample_file(
    bob.id,
    bob_research_vault.id,
    "ml_survey.pdf",
    "Mock PDF content for ML survey"
  ),
  content_type: "application/pdf",
  file_size: 10240,
  metadata: {
    category: "research",
    tags: ["machine-learning", "ai", "survey"],
    year: 2024,
    citations: 42
  }
)

bob_research_vault.documents.create!(
  title: "Performance Benchmarks",
  file_path: create_sample_file(
    bob.id,
    bob_research_vault.id,
    "benchmarks.csv",
    "test,result,time\ntest1,pass,100ms\ntest2,pass,150ms"
  ),
  content_type: "text/csv",
  file_size: 1536,
  metadata: {
    category: "research",
    tags: ["performance", "benchmarks", "testing"]
  }
)

# Charlie's team documents
charlie_vault.documents.create!(
  title: "Onboarding Guide",
  file_path: create_sample_file(
    charlie.id,
    charlie_vault.id,
    "onboarding.md",
    "# Welcome to the Team!\n\n## Getting Started\n..."
  ),
  content_type: "text/markdown",
  file_size: 3072,
  metadata: {
    category: "documentation",
    tags: ["onboarding", "team", "guide"],
    public: true
  }
)

charlie_vault.documents.create!(
  title: "Code Style Guide",
  file_path: create_sample_file(
    charlie.id,
    charlie_vault.id,
    "code_style.md",
    "# Code Style Guide\n\n## Ruby\n- Use 2 spaces for indentation..."
  ),
  content_type: "text/markdown",
  file_size: 2048,
  metadata: {
    category: "documentation",
    tags: ["coding", "style", "standards"]
  }
)

charlie_vault.documents.create!(
  title: "Meeting Notes Template",
  file_path: create_sample_file(
    charlie.id,
    charlie_vault.id,
    "meeting_template.docx",
    "Mock Word document content"
  ),
  content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  file_size: 1024,
  metadata: {
    category: "template",
    tags: ["meetings", "template"]
  }
)