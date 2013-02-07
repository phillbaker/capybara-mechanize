class Capybara::Mechanize::Node < Capybara::RackTest::Node
  def click
    if tag_name == 'a'
      super
    elsif (tag_name == 'input' and %w(submit image).include?(type)) or
        ((tag_name == 'button') and type.nil? or type == "submit")
      Capybara::Mechanize::Form.new(driver, form).submit(self)
    end
  end
end
