class Capybara::Mechanize::Node < Capybara::RackTest::Node
  def click(keys = [], offset = {})
    raise ArgumentError, "The mechanize driver does not support click options" unless keys.empty? && offset.empty?

    if tag_name == 'a'
      super
    elsif (tag_name == 'input' and %w(submit image).include?(type)) or
        ((tag_name == 'button') and type.nil? or type == "submit")
      associated_form = form
      Capybara::Mechanize::Form.new(driver, form).submit(self) if associated_form
    end
  end
end
