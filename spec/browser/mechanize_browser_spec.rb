require 'spec_helper'

describe Capybara::Mechanize::Browser do

  describe '#post_data' do

    before(:each) do
      @browser = Capybara::Mechanize::Browser.new(nil)
    end

    # Hash#to_a sorted by key
    def normalize(hash)
      hash.to_a.sort { |a,b| a[0] <=> b[0] }
    end

    it 'converts simple hash' do
      params = {
        'k1' => 'v1',
        'k2' => 'v2'
      }
        
      normalize(@browser.post_data(params)).should ==
        [['k1', 'v1'], ['k2', 'v2']]
    end

    it 'converts triply nested hash' do
      params = {
        'a' => 1,
        'b' => {
          'c' => 1,
          'd' => { 'e' => 1, 'f' => 2 }
        }
      }

      normalize(@browser.post_data(params)).should ==
        [['a', 1],
         ['b[c]', 1],
         ['b[d][e]', 1],
         ['b[d][f]', 2]]
    end

    it 'converts array of hashes' do
      params = [ { 'a' => 1 }, { 'b' => 2 } ]

      normalize(@browser.post_data(params)).should ==
        [['a', 1], ['b', 2]]
    end

  end

end
