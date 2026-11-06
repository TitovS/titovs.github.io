# Focused integration checks for branch-specific CVs using GitHub Pages-safe Liquid.
require 'jekyll'
require 'nokogiri'
require 'tmpdir'

def assert(condition, message)
  abort "CV regression: #{message}" unless condition
end

def render_cv(overrides, education_overrides = {})
  Dir.mktmpdir('cv-render-') do |destination|
    site = Jekyll::Site.new(Jekyll.configuration(
      'source' => Dir.pwd, 'destination' => destination,
      'config' => File.join(Dir.pwd, '_config.yml'),
      'plugins' => [], 'whitelist' => [], 'safe' => true,
      'quiet' => true, 'sass' => { 'cache' => false }
    ))
    site.read
    site.data['cv'] = overrides
    education_overrides.each do |id, values|
      site.data['education'][id] = site.data['education'][id].merge(values)
    end
    site.generate
    site.render
    Nokogiri::HTML(site.pages.find { |page| page.url == '/cv/' }.output)
  end
end

# Pick real source IDs dynamically so normal content additions/renames remain valid.
role_ids = Dir['_work_experience/*.md'].sort.map { |p| File.basename(p, '.md') }
paper_ids = Dir['_publications/*.md'].sort.map { |p| File.basename(p, '.md') }
assert(role_ids.size >= 2 && paper_ids.size >= 1, 'Expected source content')
chosen = role_ids.first(2).reverse
tailored = render_cv(
  'sections' => %w[publications summary experience],
  'summary' => 'A tailored **research** profile.',
  'profile' => { 'name' => 'Branch & <Co>', 'location' => '', 'email' => '' },
  'experience' => chosen, 'publications' => paper_ids.first(1),
  'experience_overrides' => {
    chosen.first => {
      'title' => 'Branch lead', 'short_description' => 'CV-only **wording**.',
      'date_start' => '', 'date_finish' => '', 'date_note' => 'Earlier experience',
      'team' => '', 'location' => '', 'highlights' => ['R&D < 5% & growing']
    }
  },
  'publication_overrides' => {
    paper_ids.first => { 'title' => 'Tailored paper', 'status' => 'accepted', 'paperurl' => '' }
  }
)
assert(tailored.at_css('h1').text == 'Branch & <Co>', 'Profile text must be escaped')
assert(tailored.css('.cv-contacts a[href^="mailto:"]').empty?, 'Empty overrides must hide contacts')
assert(tailored.css('.cv-section > h2').map { |h| h['id'] } == %w[cv-publications cv-summary cv-experience], 'Section order')
assert(tailored.css('.cv-section--experience article').map { |a| a['data-cv-id'] } == chosen, 'Explicit role order')
role = tailored.at_css('.cv-section--experience article')
assert(role.at_css('h3').text == 'Branch lead', 'Title override')
assert(role.at_css('.cv-date').text.strip == 'Earlier experience', 'Blank dates and note override')
assert(role.at_css('.cv-description strong').text == 'wording', 'Markdown summary override')
assert(role.at_css('.cv-highlights li').text == 'R&D < 5% & growing', 'Highlight escaping')
paper = tailored.at_css('.cv-publication')
assert(tailored.css('.cv-publication').size == 1, 'Publication selection')
assert(paper.at_css('h3').text.strip == 'Tailored paper' && paper.css('h3 a').empty?, 'Title and empty link overrides')
assert(paper.at_css('.cv-status').text == 'Accepted', 'Accepted status')
assert(tailored.css('.cv-error').empty?, 'Valid configuration must not show errors')

degree_id = YAML.load_file('_data/education.yml').keys.first
full = render_cv({
  'sections' => %w[experience education], 'experience_detail' => 'full',
  'experience' => chosen, 'education' => [degree_id],
  'experience_overrides' => {
    chosen.first => { 'description' => "**Project lead.**\n\nRead the [study](https://example.com/study)." }
  }
}, degree_id => {
  'thesis' => {
    'title' => 'Research & <methods>', 'description' => 'A **mixed-methods** study.',
    'url' => 'https://example.com/thesis', 'supervisor' => 'Dr Example'
  }
})
full_roles = full.css('.cv-section--experience article')
assert(full_roles.first.at_css('.cv-description strong').text == 'Project lead.', 'Full description override')
assert(full_roles.first.at_css('.cv-description a')['href'] == 'https://example.com/study', 'Full description links')
source_body = File.read("_work_experience/#{chosen.last}.md").sub(/\A---\s*\n.*?\n---\s*\n/m, '')
expected_text = Nokogiri::HTML.fragment(Kramdown::Document.new(source_body, input: 'GFM').to_html).text.gsub(/\s+/, ' ').strip
assert(full_roles.last.at_css('.cv-description').text.gsub(/\s+/, ' ').strip == expected_text, 'Full source body must be reused')
assert(full_roles.all? { |role| role['class'].include?('cv-entry--detailed') }, 'Full roles need pagination styling')
thesis = full.at_css('.cv-thesis')
assert(thesis.at_css('a').text == 'Research & <methods>', 'Thesis title escaping')
assert(thesis.at_css('a')['href'] == 'https://example.com/thesis', 'Thesis link')
assert(thesis.at_css('.cv-thesis-description strong').text == 'mixed-methods', 'Thesis Markdown description')
assert(thesis.at_css('.cv-meta').text == 'Supervisor: Dr Example', 'Thesis supervisor')

empty = render_cv('sections' => %w[summary experience education teaching awards publications],
                  'summary' => '', 'experience' => [], 'education' => [],
                  'teaching' => [], 'awards' => [], 'publications' => [])
assert(empty.css('.cv-section').empty?, 'Empty sections must not leave headings')

invalid = render_cv('sections' => ['experience'], 'experience' => ['does-not-exist'])
assert(invalid.at_css('.cv-error').text.include?('does-not-exist'), 'Missing IDs must be visible')
puts 'CV rendering regressions passed: selections, full/summary descriptions, thesis details, overrides, escaping, and missing IDs.'
