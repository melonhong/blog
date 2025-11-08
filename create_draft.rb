require 'fileutils'

# How to use
# 1. Make your template in _template/
# 2. Type the command below to create new draft from your template

# Command 
# $ ruby create_draft.rb "DRAFT_NAME" "TEMPLATE_NAME"


# +) Publish my draft: You have to install "jekyll-compose" plugin (https://github.com/jekyll/jekyll-compose)
# $ bundle exec jekyll publish _drafts/DRAFT_NAME.md --timestamp-format "%Y-%m-%d %H:%M:%S %z"

# Function to create a draft post based on a given template and title
def create_post(title, template_name)
  # Set the path to the template file
  template_path = "_templates/#{template_name}.md"
  
  # Check if the specified template exists
  unless File.exist?(template_path)
    puts "Error: Template '#{template_name}' not found in _templates."
    return
  end

  # Generate the current date and create a slug from the title
  date = Time.now.strftime('%Y-%m-%d')
  slug = title.downcase.strip.gsub(' ', '-')
  draft_path = "_drafts/#{slug}.md"

  # Read the template file and replace placeholders with actual values
  content = File.read(template_path)
  content.gsub!('{{ title }}', title)
  content.gsub!('{{ date }}', date)

  # Create the _drafts directory if it doesn't exist
  FileUtils.mkdir_p('_drafts')

  # Write the new draft to the _drafts directory
  File.write(draft_path, content)
  puts "Draft created: #{draft_path}"
end

# Main script execution
if ARGV.size < 2
  # Print usage instructions if insufficient arguments are provided
  puts "Usage: ruby create_draft.rb \"Post Title\" \"Template Name\""
else
  # Call the function with the provided title and template name
  create_post(ARGV[0], ARGV[1])
end
