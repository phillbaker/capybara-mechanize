class DisableExternalTests
  attr_accessor :tests_to_disable

  def disable(top_level_example_group)
    tests_to_disable.each do |to_disable|
      example_group = top_level_example_group

      example_description = to_disable.pop

      to_disable.each do |description|
        example_group = example_group.children.find{ |g| g.description == description }
      end

      example = example_group.examples.find{ |e| e.description == example_description }

      example.metadata[:external_test_disabled] = true unless example.nil?
    end

  end
end
