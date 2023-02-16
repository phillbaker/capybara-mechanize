# frozen_string_literal: true

class Capybara::Mechanize::Node < Capybara::RackTest::Node
  def click(keys = [], **options)
    options.delete(:offset)
    raise ArgumentError, 'The mechanize driver does not support click options' unless keys.empty? && options.empty?

    submits = respond_to?(:submits?) ? submits? :
      ((tag_name == 'input' and %w[submit image].include?(type)) or
        ((tag_name == 'button') and type.nil? or type == 'submit'))

    if tag_name == 'a' or tag_name == 'label' or
        (tag_name == 'input' and %w[checkbox radio].include?(type))
      Capybara::VERSION > '3.0.0' ? super : super()
    elsif submits
      associated_form = form
      Capybara::Mechanize::Form.new(driver, form).submit(self) if associated_form
    else
      super
    end
  end
end
