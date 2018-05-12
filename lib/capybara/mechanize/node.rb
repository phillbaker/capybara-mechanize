class Capybara::Mechanize::Node < Capybara::RackTest::Node
  def click
    if tag_name == 'a' or tag_name == 'label' or
        (tag_name == 'input' and %w(checkbox radio).include?(type))
      super
    elsif (tag_name == 'input' and %w(submit image).include?(type)) or
        ((tag_name == 'button') and type.nil? or type == "submit")
      associated_form = form
      Capybara::Mechanize::Form.new(driver, form).submit(self) if associated_form
    end
  end
end
