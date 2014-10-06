ready do
  @data_processor = DataProcessor.new("data/")
  @data_processor.import
end



#
#  Settings
#
DEFAULT_LANGUAGE = "en"

set :relative_links, true
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true,
               smartypants: true

activate :i18n, mount_at_root: DEFAULT_LANGUAGE.to_sym
activate :directory_indexes
activate :bourbon
activate :gumby

set :css_dir, "assets/stylesheets"
set :js_dir, "assets/javascripts"
set :images_dir, "assets/images"
set :fonts_dir, "assets/fonts"



#
#  Build / Environment settings
#
configure :development do
  @env = "development"

  activate :relative_assets
end

configure :build do
  @env = "build"

  activate :minify_css
  activate :minify_javascript
  activate :relative_assets
end
