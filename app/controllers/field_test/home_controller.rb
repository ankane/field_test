module FieldTest
  class HomeController < ActionController::Base
    layout false

    def index
      @experiments = FieldTest::Experiment.all.sort_by(&:id)
    end
  end
end
