class Capybara::Mechanize::Node < Capybara::RackTest::Node
  def click(keys = [], offset = {})
    raise ArgumentError, "The mechanize driver does not support click options" unless keys.empty? && offset.empty?

    if submits?
      associated_form = form
      Capybara::Mechanize::Form.new(driver, form).submit(self) if associated_form
    else
      if Capybara::VERSION > '3.0.0'
        super
      else
        super()
      end
    end
  end
end
