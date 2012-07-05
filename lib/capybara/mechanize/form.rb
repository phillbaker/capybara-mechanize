class Capybara::Mechanize::Form < Capybara::RackTest::Form
  private

  def params(button)
    if !use_mechanize?
      return super
    end

    node = {}
    # Create a fake form
    class << node
      def search(*args); []; end
    end
    node['method'] = 'POST'
    node['enctype'] = 'application/x-www-form-urlencoded'

    @m_form = Mechanize::Form.new(node)

    super

    @m_form
  end

  def merge_param!(params, key, value)
    if !use_mechanize?
      return super
    end

    if value.is_a? NilUploadedFile
      value = nil
    end

    if value.is_a? Rack::Test::UploadedFile
      @m_form.enctype = 'multipart/form-data'

      ul = Mechanize::Form::FileUpload.new({'name' => key.to_s}, value.original_filename)
      ul.file_data = value.read

      @m_form.file_uploads << ul

      return params
    end

    @m_form.fields << Mechanize::Form::Field.new({'name' => key.to_s}, value)

    params
  end

  def use_mechanize?
    driver.remote?(native['action'].to_s) && method == :post
  end
end
