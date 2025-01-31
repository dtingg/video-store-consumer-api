require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  let (:movie_data) {
    {
      "title": "Hidden Figures",
      "overview": "Some text",
      "release_date": "1960-06-16",
      "inventory": 8,
      "external_id": 100
    }
  }
  
  before do
    @movie = Movie.new(movie_data)
  end
  
  describe "Constructor" do
    it "Can be created" do
      Movie.create!(movie_data)
    end
    
    it "Has rentals" do
      @movie.must_respond_to :rentals
    end
    
    it "Has customers" do
      @movie.must_respond_to :customers
    end
  end
  
  describe "Validation" do
    it "cannot create a movie that has the same external_id as another movie" do
      Movie.create!(movie_data)
      
      duplicate_movie = Movie.new(
        title: "Hello World", 
        overview: "test test test", 
        release_date: "2019-12-12", 
        inventory: 8,
        external_id: 100
      )
      
      expect(duplicate_movie.valid?).must_equal false
      expect(duplicate_movie.errors.messages).must_include :external_id
      expect(duplicate_movie.errors.messages[:external_id]).must_include "has already been taken"
    end
    
    it "cannot create a movie with no external_id" do
      missing_movie = Movie.new(
        title: "Hello World", 
        overview: "test test test", 
        release_date: "2019-12-12", 
        inventory: 8,
      )
      
      expect(missing_movie.valid?).must_equal false
      expect(missing_movie.errors.messages).must_include :external_id
    end
  end
  
  describe "available_inventory" do
    it "Matches inventory if the movie isn't checked out" do
      # Make sure no movies are checked out
      Rental.destroy_all
      Movie.all.each do |movie|
        movie.available_inventory().must_equal movie.inventory
      end
    end
    
    it "Decreases when a movie is checked out" do
      Rental.destroy_all
      
      movie = movies(:one)
      before_ai = movie.available_inventory
      
      Rental.create!(
        customer: customers(:one),
        movie: movie,
        due_date: Date.today + 7,
        returned: false
      )
      
      movie.reload
      after_ai = movie.available_inventory
      after_ai.must_equal before_ai - 1
    end
    
    it "Increases when a movie is checked in" do
      Rental.destroy_all
      
      movie = movies(:one)
      
      rental =Rental.create!(
        customer: customers(:one),
        movie: movie,
        due_date: Date.today + 7,
        returned: false
      )
      
      movie.reload
      before_ai = movie.available_inventory
      
      rental.returned = true
      rental.save!
      
      movie.reload
      after_ai = movie.available_inventory
      after_ai.must_equal before_ai + 1
    end
  end
end
