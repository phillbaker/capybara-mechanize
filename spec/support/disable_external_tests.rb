class DisableExternalTests
  attr_accessor :tests_to_disable

  def disable(top_level_example_group)
    tests_to_disable.each do |to_disable|
      example_group = top_level_example_group

      example_description = to_disable.pop

      to_disable.each do |description|
        example_group = example_group.children.select{ |g| g.description == description }.first
      end

      example = example_group.examples.select{ |e| e.description == example_description }.first

      example.metadata[:external_test_disabled] = true
    end

  end
end
