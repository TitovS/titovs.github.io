# Validate branch configuration; optionally verify the HTML produced by Jekyll.
require 'yaml'
require 'date'

def check(condition, message)
  abort "CV: #{message}" unless condition
end

def read_yaml(path, front_matter = false)
  text = File.read(path)
  if front_matter
    match = text.match(/\A---\s*\n(.*?)\n---(?:\s*\n|\s*\z)/m)
    check(match, "Missing front matter in #{path}")
    text = match[1]
  end
  YAML.safe_load(text, permitted_classes: [Date, Time], aliases: true) || {}
end

def fields(data, allowed, context)
  check(data.is_a?(Hash), "#{context} must be a mapping")
  unknown = data.keys - allowed
  check(unknown.empty?, "Unknown fields in #{context}: #{unknown.join(', ')}")
end

def collection(directory)
  Dir["#{directory}/*.md"].sort.to_h do |path|
    [File.basename(path, '.md'), read_yaml(path, true)]
  end
end

names = %w[summary experience education skills teaching awards publications]
config = read_yaml('_data/cv.yml')
fields(config, names + %w[sections profile experience_detail experience_overrides publication_overrides], '_data/cv.yml')
check(%w[full summary].include?(config.fetch('experience_detail', 'summary')), 'experience_detail must be full or summary')
sections = config.fetch('sections', names)
check(sections.is_a?(Array) && (sections - names).empty?, 'sections must be a list of supported section names')
check(sections.uniq == sections, 'Duplicate sections')
fields(config.fetch('profile', {}), %w[name location email website github linkedin], 'profile')
check(config.fetch('profile', {}).values.all? { |v| v.is_a?(String) }, 'Profile values must be strings; use "" to hide a contact')
profile_name = config.fetch('profile', {}).fetch('name', read_yaml('_config.yml').fetch('author').fetch('name'))
check(!profile_name.strip.empty?, 'Profile name must not be empty')
check(!config.key?('summary') || config['summary'].is_a?(String), 'summary must be text')
skills = config.fetch('skills', {})
check(skills.is_a?(Hash) && skills.all? { |key, value| key.is_a?(String) && !key.strip.empty? && value.is_a?(String) && !value.strip.empty? }, 'skills must map category names to non-empty text')

sources = {
  'experience' => collection('_work_experience'),
  'publications' => collection('_publications'),
  'education' => read_yaml('_data/education.yml'),
  'teaching' => read_yaml('_data/teaching.yml')
}
sources['experience'].each do |id, role|
  next unless role.key?('highlights')
  highlights = role['highlights']
  check(highlights.is_a?(Array) && highlights.all? { |item| item.is_a?(String) }, "Highlights in _work_experience/#{id}.md must be a list of text items")
end
{
  'experience' => %w[title company team location date_start date_finish date_note short_description description highlights],
  'publications' => %w[title authors venue date status paperurl award]
}.each do |section, allowed|
  key = section == 'experience' ? 'experience_overrides' : 'publication_overrides'
  overrides = config.fetch(key, {})
  fields(overrides, sources[section].keys, key)
  overrides.each do |id, values|
    fields(values, allowed, "#{key}.#{id}")
    values.each do |field, value|
      valid = if field == 'highlights'
                value.is_a?(Array) && value.all? { |v| v.is_a?(String) }
              else
                value.is_a?(String) || (field == 'date' && value.is_a?(Date))
              end
      check(valid, "Invalid #{field} in #{key}.#{id}; use quoted text or a highlights list")
    end
    sources[section][id] = sources[section][id].merge(values)
  end
end
sources['awards'] = sources['publications'].select { |_, paper| !paper.fetch('award', '').to_s.strip.empty? }
sources['education'].each do |id, degree|
  next unless degree.key?('thesis')
  thesis = degree['thesis']
  fields(thesis, %w[title description url supervisor], "education.#{id}.thesis")
  check(thesis.values.all? { |v| v.is_a?(String) }, "Thesis details for #{id} must be strings")
  check(thesis.empty? || !thesis.fetch('title', '').strip.empty?, "Thesis title is required for #{id}")
end
selected = {}
sources.each do |section, entries|
  selection = config.fetch(section, 'all')
  if selection == 'all' || selection.nil?
    selected[section] = entries.keys
  else
    check(selection.is_a?(Array) && selection.all? { |id| id.is_a?(String) }, "#{section} must be all or an ID list")
    check(selection.uniq == selection, "Duplicate IDs in #{section}")
    check((selection - entries.keys).empty?, "Unknown #{section} IDs: #{(selection - entries.keys).join(', ')}")
    selected[section] = selection
  end
end
selected['summary'] = config.fetch('summary', '').strip.empty? ? [] : ['summary']
selected['skills'] = skills.keys

if ARGV[0]
  require 'nokogiri'
  html = File.read(ARGV[0])
  doc = Nokogiri::HTML(html)
  check(doc.at_css('.cv-document'), 'CV layout did not render')
  check(doc.css('.cv-error').empty?, 'Rendered CV contains configuration errors')
  check(doc.at_css('h1').text.strip == profile_name, 'Rendered profile name does not match configuration')
  expected_sections = sections.reject { |section| selected[section].empty? }
  actual_sections = doc.css('.cv-section > h2').map { |h| h['id'].sub('cv-', '') }
  check(actual_sections == expected_sections, 'Rendered section selection/order does not match configuration')
  if expected_sections.include?('skills')
    check(doc.css('.cv-skills dt').map(&:text) == skills.keys && doc.css('.cv-skills dd').map(&:text) == skills.values, 'Rendered skills do not match configuration')
  end
  expected_sections.reject { |s| %w[summary skills].include?(s) }.each do |section|
    ids = doc.css(".cv-section--#{section} [data-cv-id]").map { |entry| entry['data-cv-id'] }
    expected = selected[section]
    check(ids.sort == expected.sort, "Missing, extra, or duplicate entries in #{section}")
    check(ids == expected, "Wrong explicit order in #{section}") if config[section].is_a?(Array)
  end
  check(doc.at_css('#cv-print') && html.include?('window.print()'), 'Print button missing')
  check(doc.at_css('style') && html.include?('@media print'), 'Embedded print stylesheet missing')
  check(doc.css('link[rel=stylesheet], script[src], img, iframe').empty?, 'CV must display offline without external assets')
  check(!html.include?('{%') && !html.include?('{{'), 'Unrendered Liquid in HTML')
  puts 'CV configuration and rendered HTML checks passed.'
else
  puts 'CV configuration checks passed.'
end
