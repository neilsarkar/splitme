class ViewGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_view_file
    template "view.coffee", "#{views_directory}/#{file_name}_view.coffee"
    copy_file "child_view.coffee", "#{views_directory}/#{file_name}/child_view.coffee"
    template "style.sass", "#{stylesheets_directory}/#{file_name}.sass"
    puts "Don't forget to add a route to your view in router.coffee :)"
  end

  private

  def views_directory
    "app/assets/javascripts/views"
  end

  def stylesheets_directory
    "app/assets/stylesheets"
  end
end
